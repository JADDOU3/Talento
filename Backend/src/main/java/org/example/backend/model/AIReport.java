package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;

@Entity
@Table(name = "ai_report")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AIReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
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

    @Column(columnDefinition = "TEXT")
    private String mindsetScoresJson;

    @Column(columnDefinition = "TEXT")
    private String contextSummary;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;
}