package org.example.backend.Dto.activitySession;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StartActivitySessionDto {
    private Integer orderIndex;
    private int sessionId;
    private int activityId;
}
