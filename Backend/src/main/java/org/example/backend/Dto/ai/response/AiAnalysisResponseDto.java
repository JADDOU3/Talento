package org.example.backend.Dto.ai.response;

import com.fasterxml.jackson.databind.PropertyNamingStrategies;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import org.example.backend.Dto.ai.common.MindsetScoreDto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonNaming(PropertyNamingStrategies.SnakeCaseStrategy.class)
public class AiAnalysisResponseDto {
    private InstantAnalysisDto instantAnalysis;
    private UpdatedMemoryStateDto updatedMemoryState;
    private List<MindsetScoreDto> mindsetScores;
    private float analysisConfidence;
    private String analysisVersion;
}