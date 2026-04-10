package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

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
   @Enumerated(EnumType.STRING)// *** added annotation, delete comment after review ^_^ ***
   private Gender gender;// *** Changed datatype from String to Gender and  name from Gender to gender, delete comment after review ^_^ ***
   private String password;
}
