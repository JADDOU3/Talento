package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.level.Level;

@Data
public class LevelSummaryDto {
    private int id;
    private int levelNumber;
    private int difficulty;
    private String description;

    public static LevelSummaryDto from(Level level) {
        if (level == null) return null;
        LevelSummaryDto dto = new LevelSummaryDto();
        dto.setId(level.getId());
        dto.setLevelNumber(level.getLevelNumber());
        dto.setDifficulty(level.getDifficulty());
        dto.setDescription(level.getDescription());
        return dto;
    }
}
