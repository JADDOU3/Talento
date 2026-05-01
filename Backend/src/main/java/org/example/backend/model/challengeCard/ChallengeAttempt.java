package org.example.backend.model.challengeCard;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.ActivitySession;

@Entity
@Table(name = "challenge_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChallengeAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private boolean accepted;

    private boolean completed;

    private int attemptsCount;

    @ManyToOne
    @JoinColumn(name = "activity_session_id")
    private ActivitySession activitySession;

    @ManyToOne
    @JoinColumn(name = "challenge_card_id")
    private ChallengeCard challengeCard;
}