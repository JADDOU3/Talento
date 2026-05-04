package org.example.backend.service.level;

import org.example.backend.Dto.levelAttempt.CreateLevelAttemptDto;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelAttemptRepo;
import org.example.backend.repo.level.LevelRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LevelAttemptService {

    @Autowired
    private LevelAttemptRepo levelAttemptRepo;

    @Autowired
    private ActivitySessionRepo activitySessionRepo;

    @Autowired
    private LevelRepo levelRepo;

    public LevelAttempt createLevelAttempt(CreateLevelAttemptDto dto) {
        ActivitySession session = activitySessionRepo.findById(dto.getActivitySessionId()).orElse(null);
        Level level = levelRepo.findById(dto.getLevelId()).orElse(null);

        if (session == null || level == null) return null;

        LevelAttempt attempt = new LevelAttempt();
        attempt.setAttemptNumber(dto.getAttemptNumber());
        attempt.setStartedAt(dto.getStartedAt());
        attempt.setEndedAt(dto.getEndedAt());
        attempt.setCompleted(dto.getCompleted());
        attempt.setActivitySession(session);
        attempt.setLevel(level);
        return levelAttemptRepo.save(attempt);
    }

    public List<LevelAttempt> getAll() {
        return levelAttemptRepo.findAll();
    }

    public LevelAttempt getLevelAttemptById(int id) {
        return levelAttemptRepo.findById(id).orElse(null);
    }

    public List<LevelAttempt> getAttemptsByActivitySession(int activitySessionId) {
        return levelAttemptRepo.findByActivitySessionId(activitySessionId);
    }

    public LevelAttempt updateLevelAttempt(int id, CreateLevelAttemptDto dto) {
        LevelAttempt attempt = getLevelAttemptById(id);
        if (attempt != null) {
            attempt.setAttemptNumber(dto.getAttemptNumber());
            attempt.setStartedAt(dto.getStartedAt());
            attempt.setEndedAt(dto.getEndedAt());
            attempt.setCompleted(dto.getCompleted());
            return levelAttemptRepo.save(attempt);
        }
        return null;
    }

    public void deleteLevelAttempt(int id) {
        levelAttemptRepo.deleteById(id);
    }
}
