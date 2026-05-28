package org.example.backend.Dto.level;

import lombok.Data;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.level.Level;

import java.util.List;

@Data
public class LevelResponseDto {
    private int id;
    private int levelNumber;
    private int difficulty;
    private String description;
    private List<LevelImageResponseDto> images;
    private Activity activity;

    public LevelResponseDto(Level level, List<LevelImageResponseDto> images) {
        this.id = level.getId();
        this.levelNumber = level.getLevelNumber();
        this.difficulty = level.getDifficulty();
        this.description = level.getDescription();
        this.images = images;
        this.activity = level.getActivity();
    }
}