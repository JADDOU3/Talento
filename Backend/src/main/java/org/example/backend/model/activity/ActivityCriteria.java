package org.example.backend.model.activity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
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

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "criteria_id")
    private Criteria criteria;
}
