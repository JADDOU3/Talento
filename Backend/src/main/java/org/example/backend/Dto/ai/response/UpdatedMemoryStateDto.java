package org.example.backend.Dto.ai.response;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatedMemoryStateDto {
    @JsonAlias("focus_trend")
    private String focusTrend;
    @JsonAlias("confidence_trend")
    private String confidenceTrend;
    @JsonAlias("stress_response_pattern")
    private String stressResponsePattern;
    @JsonAlias("learning_behavior_pattern")
    private String learningBehaviorPattern;
    @JsonAlias("recommended_future_observation")
    private String recommendedFutureObservation;
    @JsonAlias("context_summary")
    private String contextSummary;
}