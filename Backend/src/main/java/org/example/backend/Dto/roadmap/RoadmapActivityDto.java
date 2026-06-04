package org.example.backend.Dto.roadmap;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadmapActivityDto {
    private int activityId;
    private String activityName;
    private String coverImageKey;
    private String status;
    private int currentLevelNumber;
    private int totalLevels;
    private int completedLevels;
}

