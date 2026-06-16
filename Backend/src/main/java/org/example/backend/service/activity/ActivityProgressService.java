package org.example.backend.service.activity;

import org.example.backend.Dto.progress.ActivityProgressDto;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelAttemptRepo;
import org.example.backend.repo.level.LevelRepo;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Objects;

@Service
public class ActivityProgressService {

    private final ActivitySessionRepo activitySessionRepo;
    private final LevelAttemptRepo levelAttemptRepo;
    private final LevelRepo levelRepo;

    public ActivityProgressService(
            ActivitySessionRepo activitySessionRepo,
            LevelAttemptRepo levelAttemptRepo,
            LevelRepo levelRepo
    ) {
        this.activitySessionRepo = activitySessionRepo;
        this.levelAttemptRepo = levelAttemptRepo;
        this.levelRepo = levelRepo;
    }

    /**
     * Returns the current progress for a child in a given activity session.
     * - currentLevelNumber: the level the child should play next
     * - lastChallengeIndex: the last challenge index reached in the current level (0-based)
     * - activityCompleted: true if all levels are completed in ANY activity session for this child
     *
     * The activityCompleted flag looks across ALL sessions so replaying doesn't break it.
     */
    public ActivityProgressDto getProgress(int activitySessionId) {
        ActivitySession activitySession = activitySessionRepo.findById(activitySessionId)
                .orElseThrow(() -> new jakarta.persistence.EntityNotFoundException(
                        "ActivitySession not found: " + activitySessionId));

        int activityId = activitySession.getActivity().getId();
        int childId = activitySession.getSession().getChild().getId();

        List<Level> levels = levelRepo.findByActivityIdOrderByLevelNumber(activityId);
        int totalLevels = levels.size();

        // ── Check if EVER completed across all sessions ──────────────────
        List<ActivitySession> allSessions = activitySessionRepo
                .findAllByChildIdAndActivityId(childId, activityId);

        boolean everCompleted = allSessions.stream().anyMatch(session -> {
            List<LevelAttempt> attempts = levelAttemptRepo.findByActivitySessionId(session.getId());
            long completedCount = attempts.stream()
                    .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                    .map(LevelAttempt::getLevel)
                    .filter(Objects::nonNull)
                    .map(Level::getId)
                    .distinct()
                    .count();
            return totalLevels > 0 && completedCount >= totalLevels;
        });

        // ── Current session progress ─────────────────────────────────────
        List<LevelAttempt> currentAttempts = levelAttemptRepo
                .findByActivitySessionId(activitySessionId);

        int highestCompletedLevelNumber = currentAttempts.stream()
                .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                .map(LevelAttempt::getLevel)
                .filter(Objects::nonNull)
                .map(Level::getLevelNumber)
                .max(Integer::compareTo)
                .orElse(0);

        int currentLevelNumber = highestCompletedLevelNumber + 1;
        if (totalLevels > 0 && currentLevelNumber > totalLevels) {
            currentLevelNumber = totalLevels;
        }
        if (totalLevels == 0) currentLevelNumber = 1;

        // ── Resolve current level id ─────────────────────────────────────
        final int finalCurrentLevelNumber = currentLevelNumber;
        Level currentLevel = levels.stream()
                .filter(l -> l.getLevelNumber() == finalCurrentLevelNumber)
                .findFirst()
                .orElse(levels.isEmpty() ? null : levels.get(0));

        int currentLevelId = currentLevel != null ? currentLevel.getId() : 0;

        // ── Last challenge index in current level ────────────────────────
        // Count how many attempts exist for the current level — each attempt = one challenge tried
        int lastChallengeIndex = 0;
        if (currentLevel != null) {
            long attemptsInCurrentLevel = currentAttempts.stream()
                    .filter(a -> a.getLevel() != null && a.getLevel().getId() == currentLevelId)
                    .count();
            lastChallengeIndex = (int) Math.max(0, attemptsInCurrentLevel - 1);
        }

        long completedLevels = currentAttempts.stream()
                .filter(a -> Boolean.TRUE.equals(a.getCompleted()))
                .map(LevelAttempt::getLevel)
                .filter(Objects::nonNull)
                .map(Level::getId)
                .distinct()
                .count();

        return new ActivityProgressDto(
                activityId,
                activitySessionId,
                currentLevelNumber,
                currentLevelId,
                totalLevels,
                (int) completedLevels,
                lastChallengeIndex,
                everCompleted
        );
    }
}