package org.example.backend.Dto.challenge;

import lombok.Data;

@Data
public class CreateChallengeAttemptDto {
    private int activitySessionId;
    private int challengeCardId;
}