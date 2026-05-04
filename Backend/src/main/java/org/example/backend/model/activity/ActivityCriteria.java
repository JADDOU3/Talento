package org.example.backend.model.activity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.mindset.Criteria;

@Entity
@Table(name = "activity_criteria")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityCriteria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private Float weight;

    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;

    @ManyToOne
    @JoinColumn(name = "criteria_id")
    private Criteria criteria;
}
