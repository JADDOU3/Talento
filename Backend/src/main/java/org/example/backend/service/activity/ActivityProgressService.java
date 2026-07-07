package org.example.backend.service.activity;

import jakarta.persistence.EntityNotFoundException;
import org.example.backend.Dto.activity.DailySessionCountDto;
import org.example.backend.Dto.progress.ActivityProgressResponseDto;
import org.example.backend.Dto.progress.CompletedActivitiesCountDto;
import org.example.backend.Dto.progress.LastActivityReachedDto;
import org.example.backend.model.Child;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivityProgress;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.repo.activity.ActivityProgressRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.service.ChildService;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class ActivityProgressService {

    private final ActivityProgressRepo activityProgressRepo;
    private final ActivitySessionRepo activitySessionRepo;
    private final LevelRepo levelRepo;
    private final ChildService childService;

    public ActivityProgressService(
            ActivityProgressRepo activityProgressRepo,
            ActivitySessionRepo activitySessionRepo,
            LevelRepo levelRepo,
            @Lazy ChildService childService
    ) {
        this.activityProgressRepo = activityProgressRepo;
        this.activitySessionRepo = activitySessionRepo;
        this.levelRepo = levelRepo;
        this.childService = childService;
    }

    public List<DailySessionCountDto> getWeeklySessionCounts() {
        Child child = childService.getSelectedChild();
        if (child == null) throw new EntityNotFoundException("No selected child found");

        LocalDateTime from = LocalDateTime.now().minusDays(6).toLocalDate().atStartOfDay();
        List<Object[]> raw = activitySessionRepo.countSessionsPerDayByChildId(child.getId(), from);

        // Build a map of date → count from DB results
        Map<LocalDate, Long> countMap = new LinkedHashMap<>();
        for (Object[] row : raw) {
            LocalDate date = toLocalDate(row[0]);
            long count = ((Number) row[1]).longValue();
            countMap.put(date, count);
        }

        // Fill in all 7 days — including days with 0 sessions
        List<DailySessionCountDto> result = new ArrayList<>();
        for (int i = 6; i >= 0; i--) {
            LocalDate date = LocalDate.now().minusDays(i);
            result.add(new DailySessionCountDto(
                    date.toString(),
                    countMap.getOrDefault(date, 0L)
            ));
        }

        return result;
    }

    /**
     * Normalizes the first column of the native "DATE(...)" projection to LocalDate.
     * Different JDBC driver/Hibernate versions return this as java.sql.Date,
     * java.time.LocalDate, or java.util.Date — handle all three defensively.
     */
    private LocalDate toLocalDate(Object value) {
        if (value instanceof java.sql.Date sqlDate) {
            return sqlDate.toLocalDate();
        } else if (value instanceof LocalDate localDate) {
            return localDate;
        } else if (value instanceof java.util.Date utilDate) {
            return utilDate.toInstant().atZone(java.time.ZoneId.systemDefault()).toLocalDate();
        }
        throw new IllegalStateException("Unexpected date type from query: " + value.getClass());
    }

    // ─────────────────────────────────────────────────────────────
    // Read — child inferred from JWT via ChildService
    // ─────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public ActivityProgressResponseDto getProgress(int activityId) {
        Child child = childService.getSelectedChild();
        if (child == null) throw new EntityNotFoundException("No selected child found");

        List<Level> levels = levelRepo.findByActivityIdOrderByLevelNumber(activityId);
        Level firstLevel = levels.isEmpty() ? null : levels.get(0);

        Optional<ActivityProgress> progressOpt = activityProgressRepo
                .findByChildIdAndActivityId(child.getId(), activityId);

        if (progressOpt.isEmpty()) {
            return new ActivityProgressResponseDto(
                    activityId,
                    1,
                    firstLevel != null ? firstLevel.getId() : 0,
                    0,
                    levels.size(),
                    false,
                    null
            );
        }

        return ActivityProgressResponseDto.from(progressOpt.get());
    }

    // ─────────────────────────────────────────────────────────────
    // Write — called by LevelAttemptService on completed=true
    // ─────────────────────────────────────────────────────────────

    @Transactional
    public void onLevelCompleted(int activitySessionId, int completedLevelId) {
        ActivitySession activitySession = activitySessionRepo.findById(activitySessionId)
                .orElseThrow(() -> new EntityNotFoundException(
                        "ActivitySession not found: " + activitySessionId));

        Child child = activitySession.getSession().getChild();
        Activity activity = activitySession.getActivity();

        List<Level> levels = levelRepo.findByActivityIdOrderByLevelNumber(activity.getId());
        int totalLevels = levels.size();

        Level completedLevel = levels.stream()
                .filter(l -> l.getId() == completedLevelId)
                .findFirst()
                .orElse(null);

        if (completedLevel == null) return;

        // Fetch existing or create new — avoid lambda reassignment issue
        ActivityProgress progress = activityProgressRepo
                .findByChildIdAndActivityId(child.getId(), activity.getId())
                .orElse(null);

        if (progress == null) {
            progress = new ActivityProgress();
            progress.setChild(child);
            progress.setActivity(activity);
            progress.setTotalLevels(totalLevels);
            progress.setCurrentLevelNumber(1);
            progress.setCompletedLevels(0);
            progress.setCompleted(false);
        }

        // Only advance if this level is higher than what we've recorded
        int newCompletedLevels = Math.max(
                progress.getCompletedLevels(),
                completedLevel.getLevelNumber()
        );
        progress.setCompletedLevels(newCompletedLevels);
        progress.setTotalLevels(totalLevels);

        // Advance current level to next — use final var for lambda
        int rawNext = completedLevel.getLevelNumber() + 1;
        final int nextLevelNumber = rawNext > totalLevels ? totalLevels : rawNext;

        Level nextLevel = levels.stream()
                .filter(l -> l.getLevelNumber() == nextLevelNumber)
                .findFirst()
                .orElse(completedLevel);

        if (nextLevelNumber >= progress.getCurrentLevelNumber()) {
            progress.setCurrentLevelNumber(nextLevelNumber);
            progress.setCurrentLevel(nextLevel);
        }

        // Sticky completed — never set back to false
        if (newCompletedLevels >= totalLevels) progress.setCompleted(true);

        progress.setUpdatedAt(LocalDateTime.now());
        activityProgressRepo.save(progress);
    }

    public CompletedActivitiesCountDto getCompletedActivitiesCount() {
        Child child = childService.getSelectedChild();
        if (child == null) throw new EntityNotFoundException("No selected child found");

        int count = activityProgressRepo.countByChildIdAndCompletedTrue(child.getId());
        return new CompletedActivitiesCountDto(child.getId(), count);
    }

    public LastActivityReachedDto getLastActivityReached() {
        Child child = childService.getSelectedChild();
        if (child == null) throw new EntityNotFoundException("No selected child found");
        return activityProgressRepo
                .findTopByChildIdAndUpdatedAtIsNotNullOrderByUpdatedAtDesc(child.getId())
                .map(progress -> new LastActivityReachedDto(
                        progress.getActivity().getId(),
                        progress.getActivity().getName(),
                        progress.getCurrentLevelNumber(),
                        progress.getCurrentLevel() != null ? progress.getCurrentLevel().getId() : 0,
                        progress.getTotalLevels(),
                        progress.isCompleted(),
                        progress.getUpdatedAt()
                ))
                .orElse(null);
    }
}