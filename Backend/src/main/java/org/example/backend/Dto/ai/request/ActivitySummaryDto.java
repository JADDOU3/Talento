package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivitySummaryDto {
    private int activityId;
    private String activityName;
    private String activityType;
    private int durationSeconds;
    private String completionStatus;
    private int attemptCount;
    private int hintsUsed;
    private int failCount;
    private boolean rageQuit;
    private BehavioralSignalsDto behavioralSignals;
    private List<String> behavioralObservations;
}


