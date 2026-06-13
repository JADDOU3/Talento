package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisRequestDto {
    private ChildProfileDto childProfile;
    private SessionAggregateDto sessionAggregate;
    private List<ActivitySummaryDto> activitySummaries;
    private PreviousAnalysisSummaryDto previousAnalysisSummary;
    private String parentNote;
    private String responseLanguage;
    private String analysisVersion;
}