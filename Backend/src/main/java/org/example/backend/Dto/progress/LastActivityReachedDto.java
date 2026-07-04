package org.example.backend.Dto.progress;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LastActivityReachedDto {
    private int activityId;
    private String activityName;
    private int currentLevelNumber;
    private int currentLevelId;
    private int totalLevels;
    private boolean completed;
    private java.time.LocalDateTime updatedAt;
}