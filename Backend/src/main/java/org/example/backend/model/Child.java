<<<<<<< HEAD
package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

import java.time.LocalDateTime;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Child {
    @GeneratedValue(strategy = IDENTITY)
    @Id
    private int ChildId;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;




    @Enumerated
    private Gender gender;
    private LocalDateTime createdAt;
    private String name;
    private int age;






}
=======
package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.ActivityPreference;
import org.example.backend.model.event.Event;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.util.enums.Gender;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;
import java.util.List;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Table(name = "child")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Child {
    @GeneratedValue(strategy = IDENTITY)
    @Id
    private int id;

    @Enumerated(EnumType.STRING)
    private Gender gender;

    private LocalDateTime createdAt;
    private String name;
    private int age;
    private LocalDateTime dateOfBirth;

    private boolean isSelected;

    @ManyToOne
    @JoinColumn(name = "parent_id")
    private Parent parent;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<ChildKit> childKits;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Session> sessions;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Event> events;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Performance> performances;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<ChildMindsetScore> mindsetScores;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<ActivityPreference> activityPreferences;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<AIReport> aiReports;
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e
