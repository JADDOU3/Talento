package org.example.backend.Dto.challenge.dailyChallenge;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallengeAnswerDto {
    private int challengeId;
    private String answer;
}