package org.example.backend.Dto.challenge;

import lombok.Data;
import org.example.backend.model.challengeCard.ChallengeAttempt;

@Data
public class ChallengeAttemptResponseDto {
    private int id;
    private Boolean accepted;
    private Boolean completed;
    private int attemptsCount;
    private Integer activitySessionId;
    private int challengeCardId;

    public static ChallengeAttemptResponseDto from(ChallengeAttempt attempt) {
        if (attempt == null) return null;
        ChallengeAttemptResponseDto dto = new ChallengeAttemptResponseDto();
        dto.setId(attempt.getId());
        dto.setAccepted(attempt.getAccepted());
        dto.setCompleted(attempt.getCompleted());
        dto.setAttemptsCount(attempt.getAttemptsCount());
        dto.setActivitySessionId(attempt.getActivitySession() != null ? attempt.getActivitySession().getId() : null);
        dto.setChallengeCardId(attempt.getChallengeCard() != null ? attempt.getChallengeCard().getId() : 0);
        return dto;
    }
}
