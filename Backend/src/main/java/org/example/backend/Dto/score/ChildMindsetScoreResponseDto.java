package org.example.backend.Dto.score;

import lombok.Data;
import org.example.backend.model.mindset.ChildMindsetScore;

import java.time.LocalDateTime;

@Data
public class ChildMindsetScoreResponseDto {
    private int id;
    private Float score;
    private LocalDateTime lastUpdated;
    private int childId;
    private int mindsetId;

    public static ChildMindsetScoreResponseDto from(ChildMindsetScore score) {
        if (score == null) return null;
        ChildMindsetScoreResponseDto dto = new ChildMindsetScoreResponseDto();
        dto.setId(score.getId());
        dto.setScore(score.getScore());
        dto.setLastUpdated(score.getLastUpdated());
        dto.setChildId(score.getChild() != null ? score.getChild().getId() : 0);
        dto.setMindsetId(score.getMindset() != null ? score.getMindset().getId() : 0);
        return dto;
    }
}
