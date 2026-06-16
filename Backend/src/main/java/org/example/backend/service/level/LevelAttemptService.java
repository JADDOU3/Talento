package org.example.backend.service.level;

import org.example.backend.Dto.levelAttempt.CreateLevelAttemptDto;
import org.example.backend.Dto.levelAttempt.LevelAttemptResponseDto;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelAttemptRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.service.activity.ActivityProgressService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class LevelAttemptService {

    private final LevelAttemptRepo levelAttemptRepo;
    private final ActivitySessionRepo activitySessionRepo;
    private final LevelRepo levelRepo;
    private final ActivityProgressService activityProgressService;

    public LevelAttemptService(
            LevelAttemptRepo levelAttemptRepo,
            ActivitySessionRepo activitySessionRepo,
            LevelRepo levelRepo,
            ActivityProgressService activityProgressService
    ) {
        this.levelAttemptRepo = levelAttemptRepo;
        this.activitySessionRepo = activitySessionRepo;
        this.levelRepo = levelRepo;
        this.activityProgressService = activityProgressService;
    }

    @Transactional
    public LevelAttemptResponseDto createLevelAttempt(CreateLevelAttemptDto dto) {
        ActivitySession session = activitySessionRepo.findById(dto.getActivitySessionId())
                .orElse(null);
        Level level = levelRepo.findById(dto.getLevelId()).orElse(null);
        if (session == null || level == null) return null;

        LevelAttempt attempt = new LevelAttempt();
        attempt.setAttemptNumber(dto.getAttemptNumber());
        attempt.setStartedAt(dto.getStartedAt());
        attempt.setEndedAt(dto.getEndedAt());
        attempt.setCompleted(dto.getCompleted());
        attempt.setActivitySession(session);
        attempt.setLevel(level);

        LevelAttempt saved = levelAttemptRepo.save(attempt);

        // Update progress if completed on creation
        if (Boolean.TRUE.equals(dto.getCompleted())) {
            activityProgressService.onLevelCompleted(session.getId(), level.getId());
        }

        return LevelAttemptResponseDto.from(saved);
    }

    @Transactional(readOnly = true)
    public List<LevelAttemptResponseDto> getAll() {
        return levelAttemptRepo.findAll().stream().map(LevelAttemptResponseDto::from).toList();
    }

    @Transactional(readOnly = true)
    public LevelAttemptResponseDto getLevelAttemptById(int id) {
        return levelAttemptRepo.findById(id).map(LevelAttemptResponseDto::from).orElse(null);
    }

    @Transactional(readOnly = true)
    public List<LevelAttemptResponseDto> getAttemptsByActivitySession(int activitySessionId) {
        return levelAttemptRepo.findByActivitySessionId(activitySessionId).stream()
                .map(LevelAttemptResponseDto::from).toList();
    }

    @Transactional
    public LevelAttemptResponseDto updateLevelAttempt(int id, CreateLevelAttemptDto dto) {
        LevelAttempt attempt = levelAttemptRepo.findById(id).orElse(null);
        if (attempt == null) return null;

        attempt.setAttemptNumber(dto.getAttemptNumber());
        attempt.setStartedAt(dto.getStartedAt());
        attempt.setEndedAt(dto.getEndedAt());
        attempt.setCompleted(dto.getCompleted());

        LevelAttempt saved = levelAttemptRepo.save(attempt);

        // Update progress when level is marked completed via PUT
        if (Boolean.TRUE.equals(dto.getCompleted()) && attempt.getActivitySession() != null
                && attempt.getLevel() != null) {
            activityProgressService.onLevelCompleted(
                    attempt.getActivitySession().getId(),
                    attempt.getLevel().getId()
            );
        }

        return LevelAttemptResponseDto.from(saved);
    }

    public void deleteLevelAttempt(int id) {
        levelAttemptRepo.deleteById(id);
    }
}