package org.example.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

import java.time.LocalDateTime;
import java.util.List;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Child {
    @GeneratedValue(strategy = IDENTITY)
    @Id
    private int id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @OneToMany
    @JoinColumn(name = "kit_id")
    private List<Kit> kits;



    @Enumerated(EnumType.STRING)
    private Gender gender;
    private LocalDateTime createdAt;
    private String name;
    private int age;
    @JsonIgnore
    @OneToMany(mappedBy = "child")
    private List<Session> sessions;






}
