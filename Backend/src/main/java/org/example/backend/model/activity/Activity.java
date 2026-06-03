package org.example.backend.model.activity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import org.example.backend.model.Kit;
import org.example.backend.model.Performance;
import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.model.event.Event;
import org.example.backend.model.level.Level;
import org.example.backend.util.enums.Type;

import java.util.List;

@Entity
@Table(name = "activities")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Activity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String name;

    @Enumerated(EnumType.STRING)
    private Type type;

    private String description;

    @Column(length = 2000)
    private String gameDescription;

    private String coverImageKey;

    private Boolean voiceEnabled;

    @ManyToOne
    @JoinColumn(name = "kit_id")
    private Kit kit;

    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<ActivitySession> activitySessions;



    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<Performance> performances;

    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<ActivityPreference> activityPreferences;

    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<Level> levels;

    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<ChallengeCard> challengeCards;

    @JsonIgnore
    @OneToMany(mappedBy = "activity")
    private List<Event> events;

}
