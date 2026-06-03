package org.example.backend.model.activity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.example.backend.model.Child;

import java.time.LocalDateTime;

@Entity
@Table(name = "activity_preference")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityPreference {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int timesStarted;
    private int timesRepeated;
    private int timesCompleted;
    private LocalDateTime lastPlayed;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "activity_id")
    private Activity activity;
}
