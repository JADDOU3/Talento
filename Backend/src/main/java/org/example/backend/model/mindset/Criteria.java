package org.example.backend.model.mindset;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import com.fasterxml.jackson.annotation.JsonIgnore;
import org.example.backend.model.activity.ActivityCriteria;

import java.util.List;

@Entity
@Table(name = "criteria")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Criteria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String name;
    private Float weight;

    @ManyToOne
    @JoinColumn(name = "mindset_id")
    private Mindset mindset;
    @JsonIgnore
    @OneToMany(mappedBy = "criteria")
    private List<ActivityCriteria> activityCriteria;
}
