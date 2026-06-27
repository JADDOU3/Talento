package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Entity
@Table(name = "daily_challenges")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DailyChallenge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String question;

    @ElementCollection
    @CollectionTable(name = "daily_challenge_choices",
            joinColumns = @JoinColumn(name = "challenge_id"))
    @Column(name = "choice")
    private List<String> choices;

    private String correctAnswer;
}