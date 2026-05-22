package org.example.backend.Dto.ai.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatedMemoryStateDto {
    private String focusTrend;
    private String confidenceTrend;
    private String stressResponsePattern;
    private String learningBehaviorPattern;
    private String recommendedFutureObservation;
}


