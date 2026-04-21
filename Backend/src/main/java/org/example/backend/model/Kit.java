package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Mindset;
import org.example.backend.util.enums.Type;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Entity
@Data
public class Kit {
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Id
    private int id;
    private String name;
    private String description;
    private double price;
    private LocalDateTime createdAt;
    private String imageURL;

    @Enumerated(EnumType.STRING)
    private Type type;

    @Enumerated(EnumType.STRING)
    private Mindset mindset;
    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @JsonIgnore
    @OneToMany(mappedBy = "kit")
    private List<Session> sessions;

    @JsonIgnore
    @OneToMany
    @JoinColumn(name = "kit_id")
    private List<Activity> activities;

    //todo add cartItem & OrderItem relations when they are created ^^


}
