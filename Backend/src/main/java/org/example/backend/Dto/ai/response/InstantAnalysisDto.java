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
public class InstantAnalysisDto {
    private float focusLevel;
    private float confidenceLevel;
    private float stressLevel;
    private float adaptability;
    private String decisionMakingPattern;
    private String behavioralSummary;
}