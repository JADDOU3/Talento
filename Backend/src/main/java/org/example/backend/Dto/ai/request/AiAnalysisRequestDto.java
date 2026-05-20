package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;


@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisRequestDto {
    private ChildProfileDto childProfile;
    private ActivitySummaryDto activitySummary;
    private PreviousAnalysisSummaryDto previousAnalysisSummary;
    private String responseLanguage;
    private String analysisVersion;
}


