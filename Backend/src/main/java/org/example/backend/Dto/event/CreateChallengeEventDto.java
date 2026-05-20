package org.example.backend.Dto.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.EventAction;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateChallengeEventDto {
    private int childId;
    private int sessionId;
    private EventAction action;
    private Integer activityId;
    private String responseLanguage;
}
