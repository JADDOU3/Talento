package org.example.backend.Dto.activitySession;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UpdateActivitySessionDto {
    private int id;
    private Integer orderIndex;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private int sessionId;
    private int activityId;
}
