package org.example.backend.Dto.progress;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.ActivityProgress;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityProgressResponseDto {
    private int activityId;
    private int currentLevelNumber;
    private int currentLevelId;
    private int completedLevels;
    private int totalLevels;
    private boolean completed;
    private LocalDateTime updatedAt;

    public static ActivityProgressResponseDto from(ActivityProgress progress) {
        return new ActivityProgressResponseDto(
                progress.getActivity().getId(),
                progress.getCurrentLevelNumber(),
                progress.getCurrentLevel() != null ? progress.getCurrentLevel().getId() : 0,
                progress.getCompletedLevels(),
                progress.getTotalLevels(),
                progress.isCompleted(),
                progress.getUpdatedAt()
        );
    }
}