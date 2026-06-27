package org.example.backend.Dto.challenge.dailyChallenge;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.DailyChallenge;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallengeResponseDto {
    private int id;
    private String question;
    private List<String> choices;

    public static DailyChallengeResponseDto from(DailyChallenge challenge) {
        return new DailyChallengeResponseDto(
                challenge.getId(),
                challenge.getQuestion(),
                challenge.getChoices()
        );
    }
}