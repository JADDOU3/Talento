package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Mindset;
import org.example.backend.util.Type;

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

    @Enumerated(EnumType.STRING)
    private Type type;

    @Enumerated(EnumType.STRING)
    private Mindset mindset;
    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @OneToMany
    @JoinColumn(name = "session_id")
    private List<Session> session;

    @OneToMany
    @JoinColumn(name = "activity_id")
    private List<Activity> activity;

    //todo add cartItem & OrderItem relations when they are created ^^


}
