package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Gender;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "parent")
@NoArgsConstructor
@AllArgsConstructor
@Data
public class Parent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(unique = true)
    private String email;

    private String name;

    @Enumerated(EnumType.STRING)
    private Gender gender;

    private String password;

    private String phone;

    private String location;

    private LocalDateTime createdAt;

    @JsonIgnore
    @OneToMany(mappedBy = "parent")
    private List<Child> children;

   //todo implement Web Relations
}
