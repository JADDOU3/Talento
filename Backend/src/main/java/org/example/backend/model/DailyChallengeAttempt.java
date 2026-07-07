package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "daily_challenge_attempts")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallengeAttempt{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int childId;
    private int challengeId;
    private String selectedAnswer;
    private boolean correct;
    private LocalDate attemptDate;
}