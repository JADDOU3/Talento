package org.example.backend.model.level;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.example.backend.model.activity.ActivitySession;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "level_story_submissions",
        indexes = {
                @Index(name = "idx_story_session", columnList = "activity_session_id"),
                @Index(name = "idx_story_level",   columnList = "level_id")
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelStorySubmission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String storyText;

    /**
     * The required keywords for this level, stored comma-separated.
     * All of them were confirmed present in the story — this entity is
     * only ever created on a successful keyword check.
     */
    @Column(columnDefinition = "TEXT")
    private String matchedKeywords;

    @Column(nullable = false, updatable = false)
    private LocalDateTime submittedAt;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "activity_session_id", nullable = false)
    private ActivitySession activitySession;

    @ManyToOne
    @JoinColumn(name = "level_id", nullable = false)
    private Level level;

    /**
     * Sets the timestamp automatically when Hibernate first persists this record.
     * Never call setSubmittedAt() manually.
     */
    @PrePersist
    protected void onCreate() {
        this.submittedAt = LocalDateTime.now();
    }
}