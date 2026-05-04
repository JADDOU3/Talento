package org.example.backend.service;

import org.example.backend.model.level.Level;
import org.example.backend.repo.ActivityRepo;
import org.example.backend.repo.LevelRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LevelService {

    @Autowired
    private LevelRepo levelRepo;

    @Autowired
    private ActivityRepo activityRepo;

    public Level createLevel(Level level) {
        return levelRepo.save(level);
    }

    public Level getLevelById(int id) {
        return levelRepo.findById(id).orElse(null);
    }

    public List<Level> getLevelsByActivity(int activityId) {
        return levelRepo.findByActivityIdOrderByLevelNumber(activityId);
    }

    public Level updateLevel(Level level) {
        return levelRepo.save(level);
    }

    public void deleteLevel(int id) {
        levelRepo.deleteById(id);
    }
}
