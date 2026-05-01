package org.example.backend.Dto.challenge;

import lombok.Data;
import org.example.backend.util.enums.ChallengeCardType;

@Data
public class UpdateChallengeCardDto {
    private int id;
    private ChallengeCardType type;
    private String title;
    private String description;
    private int activityId;
}