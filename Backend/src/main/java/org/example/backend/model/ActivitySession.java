package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Entity
public class ActivitySession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer orderIndex;

    private LocalDateTime startedAt;

    private LocalDateTime endedAt;

    @ManyToOne
    private Session session;

     @ManyToOne
     private Activity activity;

}
