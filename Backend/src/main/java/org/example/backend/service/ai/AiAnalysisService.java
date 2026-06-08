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
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.example.backend.model.event.Event;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.repo.AIReportRepo;
import org.example.backend.repo.PerformanceRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.challenge.ChallengeAttemptRepo;
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

@Service
public class AiAnalysisService {

    private final AiClientService aiClientService;
    private final ActivitySessionRepo activitySessionRepo;
    private final ChallengeAttemptRepo challengeAttemptRepo;
    private final HelpEventRepo helpEventRepo;
    private final AIReportRepo aiReportRepo;
    private final PerformanceRepo performanceRepo;
    private final ChildMindsetScoreRepo childMindsetScoreRepo;
    private final MindsetRepo mindsetRepo;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiAnalysisService(
            AiClientService aiClientService,
            ActivitySessionRepo activitySessionRepo,
            ChallengeAttemptRepo challengeAttemptRepo,
            HelpEventRepo helpEventRepo,
            AIReportRepo aiReportRepo,
            PerformanceRepo performanceRepo,
            ChildMindsetScoreRepo childMindsetScoreRepo,
            MindsetRepo mindsetRepo
    ) {
        this.aiClientService = aiClientService;
        this.activitySessionRepo = activitySessionRepo;
        this.challengeAttemptRepo = challengeAttemptRepo;
        this.helpEventRepo = helpEventRepo;
        this.aiReportRepo = aiReportRepo;
        this.performanceRepo = performanceRepo;
        this.childMindsetScoreRepo = childMindsetScoreRepo;
        this.mindsetRepo = mindsetRepo;
    }

    // ─────────────────────────────────────────────────────────────
    // Entry point — called by EventService on COMPLETED event
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

    /**
     * Core analysis method — shared by the real async flow and the dev test endpoint.
     * Collects all unanalyzed ActivitySessions for this child, builds one holistic
     * aggregated request, calls the AI, and persists everything.
     */
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

        // ── 4. Call AI ───────────────────────────────────────────────────
        AiAnalysisResponseDto response = aiClientService.analyze(request);
        if (response == null || response.getInstantAnalysis() == null) return null;

        // ── 5. Persist ───────────────────────────────────────────────────
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
        List<ActivitySummaryDto> activitySummaries = buildActivitySummaries(sessions);
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

    /**
     * Groups ActivitySessions by activity, then merges each group into one
     * compact ActivitySummaryDto. Hints are counted from HelpEvent records
     * (one HelpEvent per help request the child made during the session).
     */
    private List<ActivitySummaryDto> buildActivitySummaries(List<ActivitySession> sessions) {
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
            boolean anyCompleted = false;

            for (ActivitySession as : actSessions) {
                totalDuration += computeDuration(as);

                List<ChallengeAttempt> attempts = challengeAttemptRepo.findByActivitySessionId(as.getId());
                totalAttempts += attempts.stream().mapToInt(ChallengeAttempt::getAttemptsCount).sum();
                totalFails += attempts.stream().filter(a -> Boolean.FALSE.equals(a.getCompleted())).count();

                // Count help events for this session (more accurate than HelpLog @OneToOne)
                if (as.getSession() != null) {
                    totalHints += helpEventRepo.findBySessionId(as.getSession().getId()).size();
                }

                // Completed if all challenge attempts are accepted/completed and at least one exists
                long incomplete = attempts.stream().filter(a -> Boolean.FALSE.equals(a.getCompleted())).count();
                long complete = attempts.stream().filter(a -> Boolean.TRUE.equals(a.getCompleted())).count();
                if (complete > 0 && incomplete == 0) anyCompleted = true;
            }

            String completionStatus = anyCompleted ? "completed"
                    : actSessions.stream().anyMatch(s -> s.getEndedAt() != null) ? "incomplete"
                      : "abandoned";

            int avgDuration = actSessions.size() > 0 ? totalDuration / actSessions.size() : 0;

            String adaptability;
            if (actSessions.size() >= 3) {
                adaptability = "high";
            } else if (actSessions.size() == 2 || (totalFails > 0 && totalAttempts > totalFails)) {
                adaptability = "medium";
            } else {
                adaptability = "low";
            }

            BehavioralSignalsDto signals = new BehavioralSignalsDto(
                    levelByThreshold(avgDuration, 120, 300),          // hesitation
                    levelByThreshold(totalAttempts, 1, 3),             // persistence
                    adaptability,                                       // computed above
                    levelByThreshold(totalHints, 1, 3),                // hint_dependency
                    levelByThreshold(totalFails, 1, 2),                // frustration
                    levelByThreshold(avgDuration, 90, 240),            // focus
                    confidenceFrom(totalFails, totalAttempts)           // confidence
            );

            List<String> observations = List.of(
                    "sessions_count=" + actSessions.size(),
                    "total_attempts=" + totalAttempts,
                    "total_hints=" + totalHints,
                    "total_fails=" + totalFails,
                    "total_duration_seconds=" + totalDuration
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

    private SessionAggregateDto buildSessionAggregate(
            List<ActivitySession> sessions,
            List<ActivitySummaryDto> activitySummaries
    ) {
        long distinctSessions = sessions.stream()
                .map(s -> s.getSession() != null ? s.getSession().getId() : -1)
                .distinct().count();

        int totalDuration = activitySummaries.stream().mapToInt(ActivitySummaryDto::getDurationSeconds).sum();
        int totalHints = activitySummaries.stream().mapToInt(ActivitySummaryDto::getHintsUsed).sum();
        int totalFails = activitySummaries.stream().mapToInt(ActivitySummaryDto::getFailCount).sum();
        int totalAttempts = activitySummaries.stream().mapToInt(ActivitySummaryDto::getAttemptCount).sum();
        long completed = activitySummaries.stream()
                .filter(a -> "completed".equals(a.getCompletionStatus())).count();
        int total = activitySummaries.size();
        float completionRate = total > 0 ? (float) completed / total : 0f;
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
                lastReport.getContextSummary()
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

    private void savePerformances(Child child, List<ActivitySession> sessions, AiAnalysisResponseDto response) {
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

    private int computeDuration(ActivitySession s) {
        if (s.getStartedAt() != null && s.getEndedAt() != null) {
            return (int) Math.max(0, Duration.between(s.getStartedAt(), s.getEndedAt()).getSeconds());
        }
        return 0;
    }

    private String levelByThreshold(int value, int med, int high) {
        if (value >= high) return "high";
        if (value >= med) return "medium";
        return "low";
    }

    private String confidenceFrom(int failCount, int attemptCount) {
        if (attemptCount == 0) return "medium";
        if (failCount == 0) return "high";
        if (failCount >= 2) return "low";
        return "medium";
    }

    private String normalizeLanguage(String lang) {
        if (lang == null || lang.isBlank()) return "en";
        return lang.trim().toLowerCase().equals("ar") ? "ar" : "en";
    }

    private String serializeMindsetScores(List<MindsetScoreDto> scores) {
        if (scores == null || scores.isEmpty()) return null;
        try { return objectMapper.writeValueAsString(scores); } catch (Exception e) { return null; }
    }

    private List<MindsetScoreDto> parseMindsetScores(String json) {
        if (json == null || json.isBlank()) return null;
        try { return objectMapper.readValue(json, new TypeReference<>() {}); } catch (Exception e) { return null; }
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