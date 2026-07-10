package org.example.backend.model.voice;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.level.Level;

@Entity
@Table(name = "voice_overs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoiceOver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    // null = intro voice for the activity, non-null = voice for that specific level
    @ManyToOne
    @JoinColumn(name = "level_id")
    private Level level;

    private String s3Key;
}