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
