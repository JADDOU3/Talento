package org.example.backend.Dto.levelAttempt;

import lombok.Data;
import org.example.backend.Dto.common.LevelSummaryDto;
import org.example.backend.model.level.LevelAttempt;

import java.time.LocalDateTime;

@Data
public class LevelAttemptResponseDto {
    private int id;
    private int attemptNumber;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Boolean completed;
    private Integer activitySessionId;
    private LevelSummaryDto level;

    public static LevelAttemptResponseDto from(LevelAttempt attempt) {
        if (attempt == null) return null;
        LevelAttemptResponseDto dto = new LevelAttemptResponseDto();
        dto.setId(attempt.getId());
        dto.setAttemptNumber(attempt.getAttemptNumber());
        dto.setStartedAt(attempt.getStartedAt());
        dto.setEndedAt(attempt.getEndedAt());
        dto.setCompleted(attempt.getCompleted());
        dto.setActivitySessionId(attempt.getActivitySession() != null ? attempt.getActivitySession().getId() : null);
        dto.setLevel(LevelSummaryDto.from(attempt.getLevel()));
        return dto;
    }
}
