package org.example.backend.Dto.challenge.dailyChallenge;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.DailyChallenge;
import org.example.backend.model.DailyChallengeAttempt;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallengeResponseDto {
    private int id;
    private String question;
    private List<String> choices;
    private boolean alreadyAnswered;
    private Boolean correct;
    private String correctAnswer;

    public static DailyChallengeResponseDto from(DailyChallenge c) {
        return new DailyChallengeResponseDto(
                c.getId(), c.getQuestion(), c.getChoices(),
                false, null, null
        );
    }

    public static DailyChallengeResponseDto fromWithAttempt(
            DailyChallenge c, DailyChallengeAttempt a) {
        return new DailyChallengeResponseDto(
                c.getId(), c.getQuestion(), c.getChoices(),
                true, a.isCorrect(), c.getCorrectAnswer()
        );
    }
}