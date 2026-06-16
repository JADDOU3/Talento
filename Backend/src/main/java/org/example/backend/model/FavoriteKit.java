package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name="favorite_kits")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class FavoriteKit {

    @Id
    @GeneratedValue(strategy=GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name="parent_id", nullable=false)
    private Parent parent;

    @ManyToOne
    @JoinColumn(name="kit_id", nullable=false)
    private Kit kit;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt=LocalDateTime.now();
    }
}