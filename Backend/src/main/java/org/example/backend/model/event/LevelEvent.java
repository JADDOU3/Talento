package org.example.backend.model.event;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.EventAction;

@Entity
@Table(name = "level_events")
@PrimaryKeyJoinColumn(name = "event_id")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelEvent extends Event {

    @Enumerated(EnumType.STRING)
    private EventAction action;
}