package org.example.backend.Dto.aiReport;

import lombok.Data;
import org.example.backend.model.AIReport;

import java.time.LocalDateTime;

@Data
public class AIReportResponseDto {
    private int id;
    private String summary;
    private LocalDateTime generatedAt;
    private String focusTrend;
    private String confidenceTrend;
    private String stressResponsePattern;
    private String learningBehaviorPattern;
    private String recommendedFutureObservation;
    private String analysisVersion;
    private Float analysisConfidence;
    private String mindsetScoresJson;
    private int childId;

    public static AIReportResponseDto from(AIReport report) {
        if (report == null) return null;
        AIReportResponseDto dto = new AIReportResponseDto();
        dto.setId(report.getId());
        dto.setSummary(report.getSummary());
        dto.setGeneratedAt(report.getGeneratedAt());
        dto.setFocusTrend(report.getFocusTrend());
        dto.setConfidenceTrend(report.getConfidenceTrend());
        dto.setStressResponsePattern(report.getStressResponsePattern());
        dto.setLearningBehaviorPattern(report.getLearningBehaviorPattern());
        dto.setRecommendedFutureObservation(report.getRecommendedFutureObservation());
        dto.setAnalysisVersion(report.getAnalysisVersion());
        dto.setAnalysisConfidence(report.getAnalysisConfidence());
        dto.setMindsetScoresJson(report.getMindsetScoresJson());
        dto.setChildId(report.getChild() != null ? report.getChild().getId() : 0);
        return dto;
    }
}
