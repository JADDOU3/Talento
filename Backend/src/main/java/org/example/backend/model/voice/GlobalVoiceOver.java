package org.example.backend.model.voice;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.VoiceType;

@Entity
@Table(name = "global_voice_overs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class GlobalVoiceOver {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Enumerated(EnumType.STRING)
    @Column(unique = true)
    private VoiceType type;

    private String s3Key;
}