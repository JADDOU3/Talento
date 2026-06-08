package org.example.backend.Dto.ai.response;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class InstantAnalysisDto {
    @JsonAlias("focus_level")
    private float focusLevel;
    @JsonAlias("confidence_level")
    private float confidenceLevel;
    @JsonAlias("stress_level")
    private float stressLevel;
    private float adaptability;
    @JsonAlias("decision_making_pattern")
    private String decisionMakingPattern;
    @JsonAlias("behavioral_summary")
    private String behavioralSummary;
}