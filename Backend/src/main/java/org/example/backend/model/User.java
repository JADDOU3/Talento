package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

import java.util.List;

@Entity
@Table(name = "users")
@NoArgsConstructor
@AllArgsConstructor
@Data
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
   private int id;

    @Column(unique = true)
   private String email;

   private String name;
   @Enumerated(EnumType.STRING)
   private Gender gender;
   private String password;


   @OneToMany
   @JoinColumn(name = "child_id")
    private List<Child> children;

   //todo implement Web Relations
}
