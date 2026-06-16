package org.example.backend.service.roadmap;

import org.example.backend.Dto.roadmap.RoadmapActivityDto;
import org.example.backend.Dto.roadmap.RoadmapResponseDto;
import org.example.backend.model.Kit;
import org.example.backend.model.Session;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.SessionRepo;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelAttemptRepo;
import org.example.backend.repo.level.LevelRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class RoadmapService {

    @Autowired
    private ActivityRepo activityRepo;

    @Autowired
    private LevelRepo levelRepo;

    @Autowired
    private SessionRepo sessionRepo;

    @Autowired
    private ActivitySessionRepo activitySessionRepo;

    @Autowired
    private LevelAttemptRepo levelAttemptRepo;

    @Autowired
    private KitRepo kitRepo;

    public RoadmapResponseDto getRoadmap(int kitId, int childId) {
        Kit kit = kitRepo.findById(kitId).orElse(null);
        if (kit == null) return null;

        List<Activity> activities = activityRepo.findByKitIdOrderById(kitId);

        // Latest session for current level/progress display
        Session latestSession = getLatestSessionForKit(childId, kitId);
        List<ActivitySession> latestSessionActivitySessions = latestSession == null
                ? List.of()
                : activitySessionRepo.findBySessionId(latestSession.getId());
        Map<Integer, ActivitySession> latestActivitySessionByActivityId =
                mapLatestActivitySessions(latestSessionActivitySessions);

        List<RoadmapActivityDto> roadmapActivities = new ArrayList<>();
        boolean previousCompleted = true;

        for (int i = 0; i < activities.size(); i++) {
            Activity activity = activities.get(i);
            List<Level> levels = levelRepo.findByActivityIdOrderByLevelNumber(activity.getId());
            int totalLevels = levels.size();

            // ── Check completion across ALL sessions ever ────────────────
            // This preserves COMPLETED status even when the child replays.
            List<ActivitySession> allSessionsForActivity = activitySessionRepo
                    .findAllByChildIdAndActivityId(childId, activity.getId());

            boolean everCompleted = allSessionsForActivity.stream().anyMatch(session -> {
                List<LevelAttempt> attempts = levelAttemptRepo
                        .findByActivitySessionId(session.getId());
                long completedCount = attempts.stream()
                        .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                        .map(LevelAttempt::getLevel)
                        .filter(Objects::nonNull)
                        .map(Level::getId)
                        .distinct()
                        .count();
                return totalLevels > 0 && completedCount >= totalLevels;
            });

            // ── Current level/progress from latest session ───────────────
            ActivitySession latestActivitySession =
                    latestActivitySessionByActivityId.get(activity.getId());

            List<LevelAttempt> latestAttempts = latestActivitySession == null
                    ? List.of()
                    : levelAttemptRepo.findByActivitySessionId(latestActivitySession.getId());

            int completedLevels = (int) latestAttempts.stream()
                    .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                    .map(LevelAttempt::getLevel)
                    .filter(Objects::nonNull)
                    .map(Level::getId)
                    .distinct()
                    .count();

            int highestCompletedLevel = latestAttempts.stream()
                    .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                    .map(LevelAttempt::getLevel)
                    .filter(Objects::nonNull)
                    .map(Level::getLevelNumber)
                    .max(Integer::compareTo)
                    .orElse(0);

            int currentLevelNumber = highestCompletedLevel + 1;
            if (totalLevels > 0 && currentLevelNumber > totalLevels) {
                currentLevelNumber = totalLevels;
            }
            if (totalLevels == 0) currentLevelNumber = 1;

            // ── Status — COMPLETED is sticky across replays ──────────────
            String status;
            if (everCompleted) {
                status = "COMPLETED";
            } else if (latestActivitySession != null) {
                status = "CURRENT";
            } else if (i == 0 || previousCompleted) {
                status = "CURRENT";
            } else {
                status = "LOCKED";
            }

            roadmapActivities.add(new RoadmapActivityDto(
                    activity.getId(),
                    activity.getName(),
                    activity.getCoverImageKey(),
                    status,
                    currentLevelNumber,
                    totalLevels,
                    completedLevels
            ));

            previousCompleted = "COMPLETED".equals(status);
        }

        return new RoadmapResponseDto(
                kit.getId(),
                kit.getName(),
                kit.getImageURL(),
                roadmapActivities
        );
    }

    private Session getLatestSessionForKit(int childId, int kitId) {
        List<Session> sessions = sessionRepo.findByChildId(childId);
        return sessions.stream()
                .filter(s -> s.getKit() != null && s.getKit().getId() == kitId)
                .max(Comparator.comparing(this::resolveSessionTimestamp))
                .orElse(null);
    }

    private LocalDateTime resolveSessionTimestamp(Session session) {
        if (session.getEndedAt() != null) return session.getEndedAt();
        if (session.getStartedAt() != null) return session.getStartedAt();
        return LocalDateTime.MIN;
    }

    private Map<Integer, ActivitySession> mapLatestActivitySessions(
            List<ActivitySession> sessions
    ) {
        Map<Integer, ActivitySession> latestByActivity = new HashMap<>();
        for (ActivitySession session : sessions) {
            if (session.getActivity() == null) continue;
            int activityId = session.getActivity().getId();
            ActivitySession existing = latestByActivity.get(activityId);
            if (existing == null || isLaterSession(session, existing)) {
                latestByActivity.put(activityId, session);
            }
        }
        return latestByActivity;
    }

    private boolean isLaterSession(ActivitySession candidate, ActivitySession current) {
        return resolveActivitySessionTimestamp(candidate)
                .isAfter(resolveActivitySessionTimestamp(current));
    }

    private LocalDateTime resolveActivitySessionTimestamp(ActivitySession session) {
        if (session.getEndedAt() != null) return session.getEndedAt();
        if (session.getStartedAt() != null) return session.getStartedAt();
        return LocalDateTime.MIN;
    }
}