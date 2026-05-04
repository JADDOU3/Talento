package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "activity_preference")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityPreference {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int timesStarted;
    private int timesRepeated;
    private int timesCompleted;
    private LocalDateTime lastPlayed;

    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;
}
