package org.example.backend.Dto.challenge;

import lombok.Data;
import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.util.enums.ChallengeCardType;

@Data
public class ChallengeCardResponseDto {
    private int id;
    private ChallengeCardType type;
    private String title;
    private String description;
    private int activityId;

    public static ChallengeCardResponseDto from(ChallengeCard card) {
        if (card == null) return null;
        ChallengeCardResponseDto dto = new ChallengeCardResponseDto();
        dto.setId(card.getId());
        dto.setType(card.getType());
        dto.setTitle(card.getTitle());
        dto.setDescription(card.getDescription());
        dto.setActivityId(card.getActivity() != null ? card.getActivity().getId() : 0);
        return dto;
    }
}
