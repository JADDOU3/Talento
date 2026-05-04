package org.example.backend.model.challengeCard;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.Activity;
import org.example.backend.util.enums.ChallengeCardType;

@Entity
@Table(name = "challenge_cards")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChallengeCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Enumerated(EnumType.STRING)
    private ChallengeCardType type;

    private String title;

    private String description;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;
}