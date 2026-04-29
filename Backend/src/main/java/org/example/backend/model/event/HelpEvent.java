package org.example.backend.model.event;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.HelpLevel;

@Entity
@Table(name = "help_events")
@PrimaryKeyJoinColumn(name = "event_id")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class HelpEvent extends Event {

    @Enumerated(EnumType.STRING)
    private HelpLevel helpLevel;
}