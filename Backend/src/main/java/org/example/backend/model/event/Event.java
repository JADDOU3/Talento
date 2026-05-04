package org.example.backend.model.event;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.*;

import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.model.level.Level;
import org.example.backend.util.enums.EventType;

import java.time.LocalDateTime;

@Entity
@Table(name = "events")
@Inheritance(strategy = InheritanceType.JOINED)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private LocalDateTime createdAt;

    private String value; // JSON in UML, using String for simplicity or could use JsonNode

    private Float duration;

    private Boolean success;

    private int attempts;

    @ManyToOne
    @JoinColumn(name = "child_id", nullable = false)
    private Child child;

    @ManyToOne
    @JoinColumn(name = "session_id", nullable = false)
    private Session session;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;
}