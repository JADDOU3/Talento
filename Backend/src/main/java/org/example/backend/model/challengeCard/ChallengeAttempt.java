package org.example.backend.model.challengeCard;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.example.backend.model.activity.ActivitySession;

@Entity
@Table(name = "challenge_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChallengeAttempt {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private Boolean accepted;

    private Boolean completed;

    private int attemptsCount;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "activity_session_id")
    private ActivitySession activitySession;

    @ManyToOne
    @JoinColumn(name = "challenge_card_id")
    private ChallengeCard challengeCard;
}