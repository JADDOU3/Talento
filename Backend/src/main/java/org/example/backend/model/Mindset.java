package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.List;

@Entity
@Table(name = "mindset")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Mindset {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String name;
    private String description;

    @OneToMany(mappedBy = "mindset")
    private List<Criteria> criteria;
    @JsonIgnore
    @OneToMany(mappedBy = "mindset")
    private List<ChildMindsetScore> childMindsetScores;
}
