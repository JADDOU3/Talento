package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "child_kit")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChildKit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "child_id", nullable = false)
    private Child child;

    @ManyToOne
    @JoinColumn(name = "kit_id", nullable = false)
    private Kit kit;

    private LocalDateTime acquiredAt;

    private Boolean isSelected;
}