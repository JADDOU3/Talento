package org.example.backend.service;

import org.example.backend.model.level.LevelAttempt;
import org.example.backend.repo.LevelAttemptRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LevelAttemptService {

    @Autowired
    private LevelAttemptRepo levelAttemptRepo;

    public LevelAttempt createLevelAttempt(LevelAttempt attempt) {
        return levelAttemptRepo.save(attempt);
    }

    public LevelAttempt getLevelAttemptById(int id) {
        return levelAttemptRepo.findById(id).orElse(null);
    }

    public List<LevelAttempt> getAttemptsByActivitySession(int activitySessionId) {
        return levelAttemptRepo.findByActivitySessionId(activitySessionId);
    }

    public LevelAttempt updateLevelAttempt(LevelAttempt attempt) {
        return levelAttemptRepo.save(attempt);
    }

    public void deleteLevelAttempt(int id) {
        levelAttemptRepo.deleteById(id);
    }
}
