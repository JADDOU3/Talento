package org.example.backend.Dto.roadmap;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadmapCardDto {
    private int cardId;
    private int activityId;
    private String activityName;
    private String coverImageKey;
    private String coverImageUrl;
    private String status;
    private int currentLevelNumber;
    private int totalLevels;
    private int completedLevels;
    private Integer levelFrom;
    private Integer levelTo;
}