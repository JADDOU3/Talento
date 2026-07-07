package org.example.backend.Dto.challenge.dailyChallenge;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallengeResultDto {
    private boolean correct;
    private String correctAnswer;
}