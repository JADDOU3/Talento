package org.example.backend.Dto.ai.response;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class UpdatedMemoryStateDto {
    private String focusTrend;
    private String confidenceTrend;
    private String stressResponsePattern;
    private String learningBehaviorPattern;
    private String recommendedFutureObservation;
    private String contextSummary;
}