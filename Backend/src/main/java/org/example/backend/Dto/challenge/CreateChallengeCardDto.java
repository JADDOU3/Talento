package org.example.backend.Dto.challenge;

import lombok.Data;
import org.example.backend.util.enums.ChallengeCardType;

@Data
public class CreateChallengeCardDto {
    private ChallengeCardType type;
    private String title;
    private String description;
    private int activityId;
}