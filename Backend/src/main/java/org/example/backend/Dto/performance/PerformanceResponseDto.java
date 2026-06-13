package org.example.backend.Dto.performance;

import lombok.Data;
import org.example.backend.model.Performance;

import java.time.LocalDateTime;

@Data
public class PerformanceResponseDto {
    private int id;
    private Float completionScore;
    private Float efficiencyScore;
    private Float persistenceScore;
    private Float independenceScore;
    private Float strategyScore;
    private LocalDateTime lastUpdated;
    private int childId;
    private int activityId;

    public static PerformanceResponseDto from(Performance performance) {
        if (performance == null) return null;
        PerformanceResponseDto dto = new PerformanceResponseDto();
        dto.setId(performance.getId());
        dto.setCompletionScore(performance.getCompletionScore());
        dto.setEfficiencyScore(performance.getEfficiencyScore());
        dto.setPersistenceScore(performance.getPersistenceScore());
        dto.setIndependenceScore(performance.getIndependenceScore());
        dto.setStrategyScore(performance.getStrategyScore());
        dto.setLastUpdated(performance.getLastUpdated());
        dto.setChildId(performance.getChild() != null ? performance.getChild().getId() : 0);
        dto.setActivityId(performance.getActivity() != null ? performance.getActivity().getId() : 0);
        return dto;
    }
}
