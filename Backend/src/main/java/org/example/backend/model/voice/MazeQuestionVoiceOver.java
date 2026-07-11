package org.example.backend.model.voice;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.level.Level;

@Entity
@Table(
        name = "maze_question_voice_overs",
        uniqueConstraints = @UniqueConstraint(columnNames = {"level_id", "challenge_id"})
)
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MazeQuestionVoiceOver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "level_id", nullable = false)
    private Level level;

    @Column(name = "challenge_id", nullable = false)
    private int challengeId;

    private String s3Key;
}