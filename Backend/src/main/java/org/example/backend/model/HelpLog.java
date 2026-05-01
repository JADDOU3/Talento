package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.HelpLevel;

import java.time.LocalDateTime;

@Entity
@Table(name = "help_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HelpLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Enumerated(EnumType.STRING)
    private HelpLevel helpLevel;

    private LocalDateTime createdAt;

    @ManyToOne
    @JoinColumn(name = "activity_session_id")
    private ActivitySession activitySession;
}