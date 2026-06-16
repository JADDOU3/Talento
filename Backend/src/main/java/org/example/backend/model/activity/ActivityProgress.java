package org.example.backend.model.activity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.Child;
import org.example.backend.model.level.Level;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "activity_progress",
        uniqueConstraints = @UniqueConstraint(columnNames = {"child_id", "activity_id"})
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "child_id", nullable = false)
    private Child child;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    @ManyToOne
    @JoinColumn(name = "current_level_id")
    private Level currentLevel;

    private int currentLevelNumber;
    private int completedLevels;
    private int totalLevels;

    private boolean completed;

    private LocalDateTime updatedAt;
}