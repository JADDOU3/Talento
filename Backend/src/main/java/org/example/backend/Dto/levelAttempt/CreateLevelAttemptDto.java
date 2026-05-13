package org.example.backend.Dto.levelAttempt;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateLevelAttemptDto {
    private Integer attemptNumber;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Boolean completed;
    private Integer activitySessionId;
    private Integer levelId;
}
