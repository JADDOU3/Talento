package org.example.backend.service.level;

import org.example.backend.Dto.level.CreateLevelDto;
import org.example.backend.Dto.level.UpdateLevelDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.level.Level;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.level.LevelRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class LevelService {

    @Autowired
    private LevelRepo levelRepo;

    @Autowired
    private ActivityRepo activityRepo;

    public Level createLevel(CreateLevelDto dto) {
        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);
        if (activity == null) return null;

        Level level = new Level();
        level.setLevelNumber(dto.getLevelNumber());
        level.setDifficulty(dto.getDifficulty());
        level.setDescription(dto.getDescription());
        level.setActivity(activity);
        return levelRepo.save(level);
    }

    public List<Level> getAll() {
        return levelRepo.findAll();
    }

    public Level getLevelById(int id) {
        return levelRepo.findById(id).orElse(null);
    }

    public List<Level> getLevelsByActivity(int activityId) {
        return levelRepo.findByActivityIdOrderByLevelNumber(activityId);
    }

    public Level updateLevel(int id, UpdateLevelDto dto) {
        Level level = getLevelById(id);
        if (level != null) {
            level.setLevelNumber(dto.getLevelNumber());
            level.setDifficulty(dto.getDifficulty());
            level.setDescription(dto.getDescription());
            return levelRepo.save(level);
        }
        return null;
    }

    public void deleteLevel(int id) {
        levelRepo.deleteById(id);
    }
}
