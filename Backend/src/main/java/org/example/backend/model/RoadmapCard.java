package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.Activity;

@Entity
@Table(name = "roadmap_cards")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadmapCard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "kit_id", nullable = false)
    private Kit kit;

    @ManyToOne
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    private int sortOrder;

    // null = play all levels
    private Integer levelFrom;
    private Integer levelTo;
}