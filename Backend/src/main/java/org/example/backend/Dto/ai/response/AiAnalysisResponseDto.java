package org.example.backend.Dto.ai.response;

import com.fasterxml.jackson.annotation.JsonAlias;
import org.example.backend.Dto.ai.common.MindsetScoreDto;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AiAnalysisResponseDto {
    @JsonAlias("instant_analysis")
    private InstantAnalysisDto instantAnalysis;
    @JsonAlias("updated_memory_state")
    private UpdatedMemoryStateDto updatedMemoryState;
    @JsonAlias("mindset_scores")
    private List<MindsetScoreDto> mindsetScores;
    @JsonAlias("analysis_confidence")
    private float analysisConfidence;
    @JsonAlias("analysis_version")
    private String analysisVersion;
}