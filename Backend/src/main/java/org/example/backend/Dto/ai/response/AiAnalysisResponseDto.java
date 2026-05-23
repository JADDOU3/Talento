package org.example.backend.Dto.ai.response;

import org.example.backend.Dto.ai.common.MindsetScoreDto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResponseDto {
    private InstantAnalysisDto instantAnalysis;
    private UpdatedMemoryStateDto updatedMemoryState;
    private List<MindsetScoreDto> mindsetScores;
    private float analysisConfidence;
    private String analysisVersion;
}


