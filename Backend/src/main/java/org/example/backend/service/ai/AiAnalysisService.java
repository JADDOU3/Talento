package org.example.backend.service.ai;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.backend.Dto.ai.common.MindsetScoreDto;
import org.example.backend.Dto.ai.request.*;
import org.example.backend.Dto.ai.response.AiAnalysisResponseDto;
import org.example.backend.model.AIReport;
import org.example.backend.model.Child;
import org.example.backend.model.Performance;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivityProgress;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.model.event.Event;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.repo.AIReportRepo;
import org.example.backend.repo.PerformanceRepo;
import org.example.backend.repo.activity.ActivityProgressRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelAttemptRepo;
import org.example.backend.repo.event.HelpEventRepo;
import org.example.backend.repo.mindset.ChildMindsetScoreRepo;
import org.example.backend.repo.mindset.MindsetRepo;
import org.example.backend.util.enums.EventAction;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import java.util.Comparator;

@Service
public class AiAnalysisService {

    private final AiClientService aiClientService;
    private final ActivitySessionRepo activitySessionRepo;
    private final LevelAttemptRepo levelAttemptRepo;
    private final HelpEventRepo helpEventRepo;
    private final AIReportRepo aiReportRepo;
    private final PerformanceRepo performanceRepo;
    private final ChildMindsetScoreRepo childMindsetScoreRepo;
    private final MindsetRepo mindsetRepo;
    private final ActivityProgressRepo activityProgressRepo;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiAnalysisService(
            AiClientService aiClientService,
            ActivitySessionRepo activitySessionRepo,
            LevelAttemptRepo levelAttemptRepo,
            HelpEventRepo helpEventRepo,
            AIReportRepo aiReportRepo,
            PerformanceRepo performanceRepo,
            ChildMindsetScoreRepo childMindsetScoreRepo,
            MindsetRepo mindsetRepo,
            ActivityProgressRepo activityProgressRepo
    ) {
        this.aiClientService = aiClientService;
        this.activitySessionRepo = activitySessionRepo;
        this.levelAttemptRepo = levelAttemptRepo;
        this.helpEventRepo = helpEventRepo;
        this.aiReportRepo = aiReportRepo;
        this.performanceRepo = performanceRepo;
        this.childMindsetScoreRepo = childMindsetScoreRepo;
        this.mindsetRepo = mindsetRepo;
        this.activityProgressRepo = activityProgressRepo;
    }

    // ─────────────────────────────────────────────────────────────
    // Entry points
    // ─────────────────────────────────────────────────────────────

    @Async
    public void triggerAnalysisIfCompleted(Event event, String responseLanguage) {
        if (event == null || event.getChild() == null) return;
        if (event instanceof org.example.backend.model.event.ActivityEvent ae) {
            if (ae.getAction() != EventAction.COMPLETED) return;
        } else if (event instanceof org.example.backend.model.event.ChallengeEvent ce) {
            if (ce.getAction() != EventAction.COMPLETED) return;
        } else {
            return;
        }
        runAnalysis(event.getChild(), responseLanguage);
    }

    @Async
    public void runAnalysisAsync(Child child, String responseLanguage) {
        runAnalysis(child, responseLanguage);
    }

    public AiAnalysisResponseDto runAnalysis(Child child, String responseLanguage) {
        // ── 1. Find last report to get the cutoff timestamp ──────────────
        AIReport lastReport = aiReportRepo.findTopByChildIdOrderByGeneratedAtDesc(child.getId());
        LocalDateTime cutoff = lastReport != null ? lastReport.getGeneratedAt() : null;

        // ── 2. Collect unanalyzed ActivitySessions ───────────────────────
        List<ActivitySession> unanalyzed = cutoff == null
                ? activitySessionRepo.findAllByChildId(child.getId())
                : activitySessionRepo.findByChildIdAfterCutoff(child.getId(), cutoff);

        if (unanalyzed.isEmpty()) return null;

        // ── 3. Build aggregated request ──────────────────────────────────
        AiAnalysisRequestDto request = buildRequest(child, unanalyzed, lastReport, responseLanguage);
        if (request == null) return null;

        // ── 4. Log request for debugging ─────────────────────────────────
        try {
            System.out.println("=== AI REQUEST ===");
            System.out.println(objectMapper.writeValueAsString(request));
            System.out.println("=== END AI REQUEST ===");
        } catch (Exception e) {
            System.out.println("Could not serialize request: " + e.getMessage());
        }

        // ── 5. Call AI ───────────────────────────────────────────────────
        AiAnalysisResponseDto response = aiClientService.analyze(request);
        if (response == null || response.getInstantAnalysis() == null) return null;

        // ── 6. Persist ───────────────────────────────────────────────────
        saveAiReport(child, response);
        savePerformances(child, unanalyzed, response);
        saveMindsetScores(child, response.getMindsetScores());

        return response;
    }

    // ─────────────────────────────────────────────────────────────
    // Request builder
    // ─────────────────────────────────────────────────────────────

    private AiAnalysisRequestDto buildRequest(
            Child child,
            List<ActivitySession> sessions,
            AIReport lastReport,
            String responseLanguage
    ) {
        List<ActivitySummaryDto> activitySummaries = buildActivitySummaries(sessions, child);
        if (activitySummaries.isEmpty()) return null;

        SessionAggregateDto aggregate = buildSessionAggregate(sessions, activitySummaries);

        ChildProfileDto profile = new ChildProfileDto(
                child.getId(),
                child.getAge(),
                child.getGender() != null ? child.getGender().name().toLowerCase() : "",
                List.of()
        );

        AiAnalysisRequestDto request = new AiAnalysisRequestDto();
        request.setChildProfile(profile);
        request.setSessionAggregate(aggregate);
        request.setActivitySummaries(activitySummaries);
        request.setPreviousAnalysisSummary(buildPreviousAnalysisSummary(lastReport));
        request.setResponseLanguage(normalizeLanguage(responseLanguage));
        request.setAnalysisVersion(nextVersion(lastReport));
        return request;
    }

    private List<ActivitySummaryDto> buildActivitySummaries(
            List<ActivitySession> sessions,
            Child child
    ) {
        Map<Integer, List<ActivitySession>> byActivity = sessions.stream()
                .filter(s -> s.getActivity() != null)
                .collect(Collectors.groupingBy(s -> s.getActivity().getId()));

        List<ActivitySummaryDto> summaries = new ArrayList<>();

        for (Map.Entry<Integer, List<ActivitySession>> entry : byActivity.entrySet()) {
            List<ActivitySession> actSessions = entry.getValue();
            Activity activity = actSessions.get(0).getActivity();

            int totalDuration = 0;
            int totalAttempts = 0;
            int totalHints = 0;
            int totalFails = 0;
            List<LevelAttempt> allAttempts = new ArrayList<>();

            for (ActivitySession as : actSessions) {
                List<LevelAttempt> attempts = levelAttemptRepo.findByActivitySessionId(as.getId());
                allAttempts.addAll(attempts);

                totalDuration += computeDuration(as, attempts);

                // Count distinct levels attempted — not raw attempt rows
                totalAttempts += (int) attempts.stream()
                        .filter(a -> a.getLevel() != null)
                        .map(a -> a.getLevel().getId())
                        .distinct()
                        .count();

                // Count only levels where the final attempt was a failure
                Map<Integer, List<LevelAttempt>> byLevel = attempts.stream()
                        .filter(a -> a.getLevel() != null)
                        .collect(Collectors.groupingBy(a -> a.getLevel().getId()));

                for (List<LevelAttempt> levelAttempts : byLevel.values()) {
                    levelAttempts.sort(Comparator.comparingInt(LevelAttempt::getAttemptNumber));
                    LevelAttempt last = levelAttempts.get(levelAttempts.size() - 1);
                    if (Boolean.FALSE.equals(last.getCompleted())) {
                        totalFails++;
                    }
                }

                if (as.getSession() != null) {
                    totalHints += helpEventRepo.findBySessionId(as.getSession().getId()).size();
                }
            }

            int levelCount = (int) allAttempts.stream()
                    .map(a -> a.getLevel() != null ? a.getLevel().getId() : 0)
                    .distinct()
                    .filter(id -> id != 0)
                    .count();
            levelCount = Math.max(1, levelCount);

            int attemptsPerLevel = totalAttempts / levelCount;
            int failsPerLevel = totalFails / levelCount;
            int durationPerLevel = totalDuration / levelCount;

            // Single query — no double fetch
            Optional<ActivityProgress> progressOpt = activityProgressRepo
                    .findByChildIdAndActivityId(child.getId(), activity.getId());

            String completionStatus;
            int totalLevels = 1;
            int completedLevelsCount = 0;

            if (progressOpt.isPresent()) {
                ActivityProgress progress = progressOpt.get();
                totalLevels = Math.max(1, progress.getTotalLevels());
                completedLevelsCount = progress.getCompletedLevels();
                if (progress.isCompleted()) {
                    completionStatus = "completed";
                } else if (completedLevelsCount > 0) {
                    completionStatus = "partial";
                } else {
                    completionStatus = "abandoned";
                }
            } else {
                completionStatus = "abandoned";
            }

            double completionRate = (double) completedLevelsCount / totalLevels;
            double successRate = totalAttempts > 0
                    ? (double) (totalAttempts - totalFails) / totalAttempts
                    : 1.0;

            String adaptability;
            if (actSessions.size() >= 3) {
                adaptability = "high";
            } else if (actSessions.size() == 2 || (totalFails > 0 && totalAttempts > totalFails)) {
                adaptability = "medium";
            } else {
                adaptability = "low";
            }

            BehavioralSignalsDto signals = new BehavioralSignalsDto(
                    levelByThreshold(durationPerLevel, 60, 180),
                    levelByThreshold(attemptsPerLevel, 2, 4),
                    adaptability,
                    levelByThreshold(totalHints, 1, 3),
                    levelByThreshold(failsPerLevel, 1, 2),
                    levelByThreshold(durationPerLevel, 45, 150),
                    confidenceFrom(totalFails, totalAttempts)
            );

            List<String> observations = List.of(
                    "sessions_count=" + actSessions.size(),
                    "total_attempts=" + totalAttempts,
                    "attempts_per_level=" + attemptsPerLevel,
                    "total_hints=" + totalHints,
                    "total_fails=" + totalFails,
                    "fails_per_level=" + failsPerLevel,
                    "total_duration_seconds=" + totalDuration,
                    "duration_per_level_seconds=" + durationPerLevel,
                    "completion_rate=" + String.format("%.2f", completionRate),
                    "success_rate=" + String.format("%.2f", successRate),
                    "levels_completed=" + completedLevelsCount,
                    "total_levels=" + totalLevels
            );

            summaries.add(new ActivitySummaryDto(
                    activity.getId(),
                    activity.getName(),
                    activity.getType() != null ? activity.getType().name().toLowerCase() : "",
                    totalDuration,
                    completionStatus,
                    totalAttempts,
                    totalHints,
                    totalFails,
                    false,
                    signals,
                    observations
            ));
        }

        return summaries;
    }


    // ─────────────────────────────────────────────────────────────
    // Duration with LevelAttempt fallback
    // ─────────────────────────────────────────────────────────────

    private int computeDuration(ActivitySession s, List<LevelAttempt> attempts) {
        // Primary: session start/end
        if (s.getStartedAt() != null && s.getEndedAt() != null) {
            return (int) Math.max(0,
                    Duration.between(s.getStartedAt(), s.getEndedAt()).getSeconds());
        }

        // Fallback 1: sum LevelAttempt durations
        if (attempts != null && !attempts.isEmpty()) {
            int total = 0;
            for (LevelAttempt attempt : attempts) {
                if (attempt.getStartedAt() != null && attempt.getEndedAt() != null) {
                    total += (int) Math.max(0,
                            Duration.between(attempt.getStartedAt(), attempt.getEndedAt()).getSeconds());
                }
            }
            if (total > 0) return total;
        }

        // Fallback 2: session startedAt to now, capped at 1 hour
        if (s.getStartedAt() != null) {
            return (int) Math.min(
                    Duration.between(s.getStartedAt(), LocalDateTime.now()).getSeconds(),
                    3600
            );
        }

        return 0;
    }

    // ─────────────────────────────────────────────────────────────
    // Session aggregate
    // ─────────────────────────────────────────────────────────────

    private SessionAggregateDto buildSessionAggregate(
            List<ActivitySession> sessions,
            List<ActivitySummaryDto> activitySummaries
    ) {
        long distinctSessions = sessions.stream()
                .map(s -> s.getSession() != null ? s.getSession().getId() : -1)
                .distinct().count();

        int totalDuration = activitySummaries.stream()
                .mapToInt(ActivitySummaryDto::getDurationSeconds).sum();
        int totalHints = activitySummaries.stream()
                .mapToInt(ActivitySummaryDto::getHintsUsed).sum();
        int totalFails = activitySummaries.stream()
                .mapToInt(ActivitySummaryDto::getFailCount).sum();
        int totalAttempts = activitySummaries.stream()
                .mapToInt(ActivitySummaryDto::getAttemptCount).sum();
        long completed = activitySummaries.stream()
                .filter(a -> "completed".equals(a.getCompletionStatus())).count();
        long partial = activitySummaries.stream()
                .filter(a -> "partial".equals(a.getCompletionStatus())).count();
        int total = activitySummaries.size();

        // partial counts as 0.5 toward completion rate
        float completionRate = total > 0
                ? (float) (completed + partial * 0.5) / total
                : 0f;
        int avgDuration = total > 0 ? totalDuration / total : 0;

        return new SessionAggregateDto(
                (int) distinctSessions,
                total,
                totalDuration,
                (int) completed,
                completionRate,
                totalHints,
                totalFails,
                totalAttempts,
                0,
                avgDuration
        );
    }

    private PreviousAnalysisSummaryDto buildPreviousAnalysisSummary(AIReport lastReport) {
        if (lastReport == null) return null;
        List<MindsetScoreDto> scores = parseMindsetScores(lastReport.getMindsetScoresJson());
        if (scores != null) {
            scores = scores.stream()
                    .filter(s -> s.getMindsetName() != null && !s.getMindsetName().isBlank())
                    .collect(Collectors.toList());
        }
        return new PreviousAnalysisSummaryDto(
                lastReport.getFocusTrend(),
                lastReport.getConfidenceTrend(),
                lastReport.getStressResponsePattern(),
                lastReport.getLearningBehaviorPattern(),
                scores,
                lastReport.getGeneratedAt() != null ? lastReport.getGeneratedAt().toString() : null,
                lastReport.getAnalysisVersion(),
                lastReport.getContextSummary() // now properly chained
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Persistence
    // ─────────────────────────────────────────────────────────────

    private void saveAiReport(Child child, AiAnalysisResponseDto response) {
        AIReport report = new AIReport();
        report.setChild(child);
        report.setSummary(response.getInstantAnalysis().getBehavioralSummary());
        report.setGeneratedAt(LocalDateTime.now());
        if (response.getUpdatedMemoryState() != null) {
            report.setFocusTrend(response.getUpdatedMemoryState().getFocusTrend());
            report.setConfidenceTrend(response.getUpdatedMemoryState().getConfidenceTrend());
            report.setStressResponsePattern(response.getUpdatedMemoryState().getStressResponsePattern());
            report.setLearningBehaviorPattern(response.getUpdatedMemoryState().getLearningBehaviorPattern());
            report.setRecommendedFutureObservation(response.getUpdatedMemoryState().getRecommendedFutureObservation());
            report.setContextSummary(response.getUpdatedMemoryState().getContextSummary());
        }
        report.setAnalysisVersion(response.getAnalysisVersion());
        report.setAnalysisConfidence(response.getAnalysisConfidence());
        report.setMindsetScoresJson(serializeMindsetScores(response.getMindsetScores()));
        aiReportRepo.save(report);
    }

    private void savePerformances(Child child, List<ActivitySession> sessions,
                                  AiAnalysisResponseDto response) {
        var instant = response.getInstantAnalysis();
        if (instant == null) return;

        Set<Integer> seen = new HashSet<>();
        for (ActivitySession as : sessions) {
            if (as.getActivity() == null) continue;
            Activity activity = as.getActivity();
            if (!seen.add(activity.getId())) continue;

            Performance p = performanceRepo
                    .findByChildIdAndActivityId(child.getId(), activity.getId())
                    .orElse(new Performance());

            p.setChild(child);
            p.setActivity(activity);
            p.setCompletionScore(avg(instant.getFocusLevel(), instant.getConfidenceLevel()));
            p.setEfficiencyScore(instant.getAdaptability());
            p.setPersistenceScore(instant.getFocusLevel());
            p.setIndependenceScore(instant.getConfidenceLevel());
            p.setStrategyScore(clamp(1.0f - instant.getStressLevel()));
            p.setLastUpdated(LocalDateTime.now());
            performanceRepo.save(p);
        }
    }

    private void saveMindsetScores(Child child, List<MindsetScoreDto> scores) {
        if (scores == null || scores.isEmpty()) return;
        for (MindsetScoreDto dto : scores) {
            if (dto.getMindsetName() == null || dto.getMindsetName().isBlank()) continue;
            Mindset mindset = mindsetRepo.findByName(dto.getMindsetName());
            if (mindset == null) continue;
            ChildMindsetScore score = childMindsetScoreRepo
                    .findByChildIdAndMindsetId(child.getId(), mindset.getId())
                    .orElse(new ChildMindsetScore());
            score.setChild(child);
            score.setMindset(mindset);
            score.setScore(dto.getScore());
            score.setLastUpdated(LocalDateTime.now());
            childMindsetScoreRepo.save(score);
        }
    }

    // ─────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────

    private String levelByThreshold(int value, int med, int high) {
        if (value >= high) return "high";
        if (value >= med) return "medium";
        return "low";
    }

    private String confidenceFrom(int failCount, int attemptCount) {
        if (attemptCount == 0) return "medium";
        if (failCount == 0) return "high";
        double failRate = (double) failCount / attemptCount;
        if (failRate >= 0.5) return "low";
        if (failRate >= 0.25) return "medium";
        return "high";
    }

    private String normalizeLanguage(String lang) {
        if (lang == null || lang.isBlank()) return "en";
        return lang.trim().toLowerCase().equals("ar") ? "ar" : "en";
    }

    private String serializeMindsetScores(List<MindsetScoreDto> scores) {
        if (scores == null || scores.isEmpty()) return null;
        try {
            return objectMapper.writeValueAsString(scores);
        } catch (Exception e) {
            return null;
        }
    }

    private List<MindsetScoreDto> parseMindsetScores(String json) {
        if (json == null || json.isBlank()) return null;
        try {
            return objectMapper.readValue(json, new TypeReference<>() {});
        } catch (Exception e) {
            return null;
        }
    }

    private float avg(float a, float b) { return (a + b) / 2.0f; }
    private float clamp(float v) { return Math.max(0.0f, Math.min(1.0f, v)); }

    private String nextVersion(AIReport lastReport) {
        if (lastReport == null || lastReport.getAnalysisVersion() == null) return "v1";
        try {
            String last = lastReport.getAnalysisVersion().toLowerCase().replaceAll("[^0-9]", "");
            int next = Integer.parseInt(last) + 1;
            return "v" + next;
        } catch (NumberFormatException e) {
            return "v1";
        }
    }
}