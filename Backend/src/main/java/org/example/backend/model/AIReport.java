package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "ai_report")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AIReport {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String summary;
    private LocalDateTime generatedAt;

    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;
}
