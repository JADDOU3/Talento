package org.example.backend.Dto.progress;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CompletedActivitiesCountDto {
    private int childId;
    private int completedActivities;
}