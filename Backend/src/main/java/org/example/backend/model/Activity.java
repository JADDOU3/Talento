package org.example.backend.model;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

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
    private String description;

    private String type; // todo change it to enum later when we know the types of activities we will have

//    @ManyToOne
//    @JoinColumn(name = "KitId")
//    private Kit kit;
// todo add this relation when kit is created


//todo add the other relations when they are created

}
