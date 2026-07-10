package org.example.backend.Dto.aiReport;

import lombok.Data;
import org.example.backend.Dto.ai.common.MindsetScoreDto;
import org.example.backend.model.AIReport;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class AIReportResponseDto {
    private int id;
    private int childId;
    private String summary;
    private LocalDateTime generatedAt;
    private String focusTrend;
    private String confidenceTrend;
    private String stressResponsePattern;
    private String learningBehaviorPattern;
    private String recommendedFutureObservation;
    private String contextSummary;
    private String analysisVersion;
    private Float analysisConfidence;
    private List<MindsetScoreDto> mindsetScores;

    private static final ObjectMapper mapper = new ObjectMapper();

    public static AIReportResponseDto from(AIReport report) {
        if (report == null) return null;
        AIReportResponseDto dto = new AIReportResponseDto();
        dto.setId(report.getId());
        dto.setChildId(report.getChild() != null ? report.getChild().getId() : 0);
        dto.setSummary(report.getSummary());
        dto.setGeneratedAt(report.getGeneratedAt());
        dto.setFocusTrend(report.getFocusTrend());
        dto.setConfidenceTrend(report.getConfidenceTrend());
        dto.setStressResponsePattern(report.getStressResponsePattern());
        dto.setLearningBehaviorPattern(report.getLearningBehaviorPattern());
        dto.setRecommendedFutureObservation(report.getRecommendedFutureObservation());
        dto.setContextSummary(report.getContextSummary());
        dto.setAnalysisVersion(report.getAnalysisVersion());
        dto.setAnalysisConfidence(report.getAnalysisConfidence());
        dto.setMindsetScores(parseMindsetScores(report.getMindsetScoresJson()));
        return dto;
    }

    private static List<MindsetScoreDto> parseMindsetScores(String json) {
        if (json == null || json.isBlank()) return List.of();
        try {
            return mapper.readValue(json, new TypeReference<>() {});
        } catch (Exception e) {
            return List.of();
        }
    }
}