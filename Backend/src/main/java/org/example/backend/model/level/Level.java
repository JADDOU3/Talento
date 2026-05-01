package org.example.backend.model.level;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.Activity;

@Entity
@Table(name = "levels")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Level {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int levelNumber;

    private int difficulty;

    private String description;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;
}