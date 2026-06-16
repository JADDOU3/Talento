package org.example.backend.Dto.progress;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityProgressDto {
    private int activityId;
    private int activitySessionId;
    private int currentLevelNumber;
    private int currentLevelId;
    private int totalLevels;
    private int completedLevels;

    private int lastChallengeIndex;
    private boolean activityCompleted;
}