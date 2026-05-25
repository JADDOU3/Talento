package org.example.backend.Dto.ai.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InstantAnalysisDto {
    private float focusLevel;
    private float confidenceLevel;
    private float stressLevel;
    private float adaptability;
    private String decisionMakingPattern;
    private String behavioralSummary;
}


