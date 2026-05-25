package org.example.backend.service.ai;

import org.example.backend.Dto.ai.common.MindsetScoreDto;
import org.example.backend.Dto.ai.request.AiAnalysisRequestDto;
import org.example.backend.Dto.ai.request.ActivitySummaryDto;
import org.example.backend.Dto.ai.request.BehavioralSignalsDto;
import org.example.backend.Dto.ai.request.ChildProfileDto;
import org.example.backend.Dto.ai.request.PreviousAnalysisSummaryDto;
import org.example.backend.Dto.ai.response.AiAnalysisResponseDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.example.backend.model.AIReport;
import org.example.backend.model.Child;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.example.backend.model.event.Event;
import org.example.backend.repo.AIReportRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.challenge.ChallengeAttemptRepo;
import org.example.backend.repo.event.HelpEventRepo;
import org.example.backend.util.enums.EventAction;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class AiAnalysisService {
    private final AiClientService aiClientService;
    private final ActivitySessionRepo activitySessionRepo;
    private final ChallengeAttemptRepo challengeAttemptRepo;
    private final HelpEventRepo helpEventRepo;
    private final AIReportRepo aiReportRepo;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public AiAnalysisService(
        AiClientService aiClientService,
        ActivitySessionRepo activitySessionRepo,
        ChallengeAttemptRepo challengeAttemptRepo,
        HelpEventRepo helpEventRepo,
        AIReportRepo aiReportRepo
    ) {
        this.aiClientService = aiClientService;
        this.activitySessionRepo = activitySessionRepo;
        this.challengeAttemptRepo = challengeAttemptRepo;
        this.helpEventRepo = helpEventRepo;
        this.aiReportRepo = aiReportRepo;
    }

    @Async
    public void triggerAnalysisIfCompleted(Event event, String responseLanguage) {
        if (event == null || event.getActivity() == null || event.getChild() == null || event.getSession() == null) {
            return;
        }
        if (!(event instanceof org.example.backend.model.event.ActivityEvent
            || event instanceof org.example.backend.model.event.ChallengeEvent)) {
            return;
        }
        if (event instanceof org.example.backend.model.event.ActivityEvent) {
            org.example.backend.model.event.ActivityEvent activityEvent =
                (org.example.backend.model.event.ActivityEvent) event;
            if (activityEvent.getAction() != EventAction.COMPLETED) {
                return;
            }
        }
        if (event instanceof org.example.backend.model.event.ChallengeEvent) {
            org.example.backend.model.event.ChallengeEvent challengeEvent =
                (org.example.backend.model.event.ChallengeEvent) event;
            if (challengeEvent.getAction() != EventAction.COMPLETED) {
                return;
            }
        }

        AiAnalysisRequestDto request = buildRequest(event, responseLanguage);
        if (request == null) {
            return;
        }
        AiAnalysisResponseDto response = aiClientService.analyze(request);
        if (response == null || response.getInstantAnalysis() == null) {
            return;
        }
        AIReport report = new AIReport();
        report.setChild(event.getChild());
        report.setSummary(response.getInstantAnalysis().getBehavioralSummary());
        report.setGeneratedAt(LocalDateTime.now());
        if (response.getUpdatedMemoryState() != null) {
            report.setFocusTrend(response.getUpdatedMemoryState().getFocusTrend());
            report.setConfidenceTrend(response.getUpdatedMemoryState().getConfidenceTrend());
            report.setStressResponsePattern(response.getUpdatedMemoryState().getStressResponsePattern());
            report.setLearningBehaviorPattern(response.getUpdatedMemoryState().getLearningBehaviorPattern());
            report.setRecommendedFutureObservation(response.getUpdatedMemoryState().getRecommendedFutureObservation());
        }
        report.setAnalysisVersion(response.getAnalysisVersion());
        report.setAnalysisConfidence(response.getAnalysisConfidence());
        report.setMindsetScoresJson(serializeMindsetScores(response.getMindsetScores()));
        aiReportRepo.save(report);
    }

    private AiAnalysisRequestDto buildRequest(Event event, String responseLanguage) {
        Child child = event.getChild();
        Activity activity = event.getActivity();
        ActivitySession activitySession = resolveActivitySession(event);
        if (child == null || activity == null) {
            return null;
        }

        int durationSeconds = resolveDurationSeconds(event, activitySession);
        int attemptCount = resolveAttemptCount(activitySession, event);
        int hintsUsed = helpEventRepo.findBySessionId(event.getSession().getId()).size();
        int failCount = resolveFailCount(activitySession);

        List<String> observations = new ArrayList<>();
        observations.add("attempts=" + attemptCount);
        observations.add("hints_used=" + hintsUsed);
        observations.add("fails=" + failCount);
        observations.add("duration_seconds=" + durationSeconds);

        BehavioralSignalsDto signals = new BehavioralSignalsDto(
            levelByThreshold(durationSeconds, 120, 300),
            levelByThreshold(attemptCount, 1, 3),
            "medium",
            levelByThreshold(hintsUsed, 1, 3),
            levelByThreshold(failCount, 1, 2),
            levelByThreshold(durationSeconds, 90, 240),
            confidenceFrom(failCount, attemptCount)
        );

        ActivitySummaryDto summary = new ActivitySummaryDto(
            activity.getId(),
            activity.getName(),
            activity.getType() != null ? activity.getType().name().toLowerCase() : "",
            durationSeconds,
            "completed",
            attemptCount,
            hintsUsed,
            failCount,
            false,
            signals,
            observations
        );

        ChildProfileDto profile = new ChildProfileDto(
            child.getId(),
            child.getAge(),
            child.getGender() != null ? child.getGender().name().toLowerCase() : "",
            List.of()
        );

        AiAnalysisRequestDto request = new AiAnalysisRequestDto();
        request.setChildProfile(profile);
        request.setActivitySummary(summary);
        request.setPreviousAnalysisSummary(buildPreviousAnalysisSummary(child));
        request.setResponseLanguage(normalizeLanguage(responseLanguage));
        request.setAnalysisVersion("v1");
        return request;
    }

    private PreviousAnalysisSummaryDto buildPreviousAnalysisSummary(Child child) {
        AIReport lastReport = aiReportRepo.findTopByChildIdOrderByGeneratedAtDesc(child.getId());
        if (lastReport == null) {
            return null;
        }
        List<MindsetScoreDto> scores = parseMindsetScores(lastReport.getMindsetScoresJson());
        return new PreviousAnalysisSummaryDto(
            lastReport.getFocusTrend(),
            lastReport.getConfidenceTrend(),
            lastReport.getStressResponsePattern(),
            lastReport.getLearningBehaviorPattern(),
            scores,
            lastReport.getGeneratedAt() != null ? lastReport.getGeneratedAt().toString() : null,
            lastReport.getAnalysisVersion()
        );
    }

    private String serializeMindsetScores(List<MindsetScoreDto> scores) {
        if (scores == null || scores.isEmpty()) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(scores);
        } catch (Exception ex) {
            return null;
        }
    }

    private List<MindsetScoreDto> parseMindsetScores(String json) {
        if (json == null || json.isBlank()) {
            return null;
        }
        try {
            return objectMapper.readValue(json, new TypeReference<List<MindsetScoreDto>>() {});
        } catch (Exception ex) {
            return null;
        }
    }

    private ActivitySession resolveActivitySession(Event event) {
        List<ActivitySession> sessions = activitySessionRepo.findBySessionId(event.getSession().getId());
        return sessions.stream()
            .filter(s -> s.getActivity() != null && s.getActivity().getId() == event.getActivity().getId())
            .filter(s -> s.getStartedAt() != null)
            .max(Comparator.comparing(ActivitySession::getStartedAt))
            .orElse(null);
    }

    private int resolveDurationSeconds(Event event, ActivitySession activitySession) {
        if (event.getDuration() != null) {
            return Math.max(0, Math.round(event.getDuration()));
        }
        if (activitySession != null && activitySession.getStartedAt() != null && activitySession.getEndedAt() != null) {
            long seconds = Duration.between(activitySession.getStartedAt(), activitySession.getEndedAt()).getSeconds();
            return (int) Math.max(0, seconds);
        }
        return 0;
    }

    private int resolveAttemptCount(ActivitySession activitySession, Event event) {
        int attempts = event.getAttempts();
        if (activitySession == null) {
            return attempts;
        }
        List<ChallengeAttempt> challengeAttempts = challengeAttemptRepo.findByActivitySessionId(activitySession.getId());
        int summed = challengeAttempts.stream().mapToInt(ChallengeAttempt::getAttemptsCount).sum();
        return Math.max(attempts, summed);
    }

    private int resolveFailCount(ActivitySession activitySession) {
        if (activitySession == null) {
            return 0;
        }
        List<ChallengeAttempt> attempts = challengeAttemptRepo.findByActivitySessionId(activitySession.getId());
        return (int) attempts.stream().filter(a -> Boolean.FALSE.equals(a.getCompleted())).count();
    }

    private String levelByThreshold(int value, int mediumThreshold, int highThreshold) {
        if (value >= highThreshold) {
            return "high";
        }
        if (value >= mediumThreshold) {
            return "medium";
        }
        return "low";
    }

    private String confidenceFrom(int failCount, int attemptCount) {
        if (attemptCount == 0) {
            return "medium";
        }
        if (failCount == 0) {
            return "high";
        }
        if (failCount >= 2) {
            return "low";
        }
        return "medium";
    }

    private String normalizeLanguage(String responseLanguage) {
        if (responseLanguage == null || responseLanguage.isBlank()) {
            return "en";
        }
        String normalized = responseLanguage.trim().toLowerCase();
        return normalized.equals("ar") ? "ar" : "en";
    }
}
