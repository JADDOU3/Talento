package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SessionAggregateDto {
    private int totalSessions;
    private int totalActivitiesAttempted;
    private int totalDurationSeconds;
    private int completedActivities;
    private float completionRate;
    private int totalHintsUsed;
    private int totalFails;
    private int totalAttempts;
    private int rageQuitCount;
    private int avgDurationPerActivitySeconds;
}