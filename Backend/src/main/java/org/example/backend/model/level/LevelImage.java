package org.example.backend.model.level;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "level_images")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelImage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String s3Key;
    private String role;
    private String label;

    @Column(length = 500)
    private String description;

    private Integer sortOrder;

    @Column(length = 2000)
    private String meta;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "level_id")
    private Level level;
}

