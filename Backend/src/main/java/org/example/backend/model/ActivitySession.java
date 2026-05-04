package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.example.backend.model.level.LevelAttempt;

import java.time.LocalDateTime;
import java.util.List;

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


    @OneToMany(mappedBy = "activitySession", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<LevelAttempt> levelAttempts;

    @OneToMany(mappedBy = "activitySession", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChallengeAttempt> challengeAttempts;

    @OneToOne(mappedBy = "activitySession")
    private HelpLog helpLog;

}
