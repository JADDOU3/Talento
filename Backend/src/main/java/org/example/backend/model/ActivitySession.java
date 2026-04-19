package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
public class ActivitySession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int orderIndex;

    private LocalDateTime startedAt;

    private LocalDateTime endedAt;

    @ManyToOne
    @JoinColumn(name = "session_id")
    private Session session;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;


    //todo add the other relations when they are created ( LevelAttempts , HelpLog , ChallengeAttempt )

}
