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
import org.example.backend.service.ai.AiAnalysisService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class LevelAttemptService {

    private final LevelAttemptRepo levelAttemptRepo;
    private final ActivitySessionRepo activitySessionRepo;
    private final LevelRepo levelRepo;
    private final ActivityProgressService activityProgressService;
    private final AiAnalysisService aiAnalysisService;

    public LevelAttemptService(
            LevelAttemptRepo levelAttemptRepo,
            ActivitySessionRepo activitySessionRepo,
            LevelRepo levelRepo,
            ActivityProgressService activityProgressService,
            AiAnalysisService aiAnalysisService
    ) {
        this.levelAttemptRepo = levelAttemptRepo;
        this.activitySessionRepo = activitySessionRepo;
        this.levelRepo = levelRepo;
        this.activityProgressService = activityProgressService;
        this.aiAnalysisService = aiAnalysisService;
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

        if (Boolean.TRUE.equals(dto.getCompleted())) {
            onLevelAttemptCompleted(session, level);
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

        // Read these BEFORE save while still in an active persistence context
        ActivitySession session = attempt.getActivitySession();
        Level level = attempt.getLevel();

        LevelAttempt saved = levelAttemptRepo.save(attempt);

        if (Boolean.TRUE.equals(dto.getCompleted()) && session != null && level != null) {
            onLevelAttemptCompleted(session, level);
        }

        return LevelAttemptResponseDto.from(saved);
    }

    public void deleteLevelAttempt(int id) {
        levelAttemptRepo.deleteById(id);
    }


    private void onLevelAttemptCompleted(ActivitySession session, Level level) {
        activityProgressService.onLevelCompleted(session.getId(), level.getId());

        if (level.isMilestone()) {
            aiAnalysisService.runAnalysisAsync(session.getSession().getChild(), "en");
        }
    }
}