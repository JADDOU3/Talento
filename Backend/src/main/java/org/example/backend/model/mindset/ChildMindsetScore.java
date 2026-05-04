package org.example.backend.model.mindset;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.Child;

import java.time.LocalDateTime;

@Entity
@Table(name = "child_mindset_score")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChildMindsetScore {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private Float score;
    private LocalDateTime lastUpdated;

    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @ManyToOne
    @JoinColumn(name = "mindset_id")
    private Mindset mindset;
}
