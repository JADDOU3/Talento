package org.example.backend.model.level;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.ActivitySession;

import java.time.LocalDateTime;

@Entity
@Table(name = "level_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int attemptNumber;

    private LocalDateTime startedAt;

    private LocalDateTime endedAt;

    private boolean completed;

    @ManyToOne
    @JoinColumn(name = "activity_session_id")
    private ActivitySession activitySession;

    @ManyToOne
    @JoinColumn(name = "level_id")
    private Level level;
}