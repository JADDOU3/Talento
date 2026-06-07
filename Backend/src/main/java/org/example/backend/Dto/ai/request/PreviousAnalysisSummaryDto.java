package org.example.backend.Dto.ai.request;

import org.example.backend.Dto.ai.common.MindsetScoreDto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PreviousAnalysisSummaryDto {
    private String focusTrend;
    private String confidenceTrend;
    private String stressResponsePattern;
    private String learningBehaviorPattern;
    private List<MindsetScoreDto> mindsetScores;
    private String lastUpdated;
    private String analysisVersion;
    private String contextSummary;
}