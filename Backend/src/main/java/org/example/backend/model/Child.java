package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
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
    private LocalDateTime dateOfBirth;

    private boolean isSelected;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Kit> kits;


    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Session> sessions;


    //todo add Relations ( Mindset Profiling , Performance , ActivityPreference , Event , ChildMission) when implemented

}
