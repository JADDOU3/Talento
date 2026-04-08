package org.example.backend.model;

import jakarta.persistence.*;
import org.example.backend.util.Gender;

import java.time.LocalDateTime;

import static jakarta.persistence.GenerationType.IDENTITY;

@Entity
public class Child {
    @GeneratedValue(strategy = IDENTITY)
    @Id
    private int ChildId;

    @ManyToOne
    @JoinColumn(name = "parent_id")
    Parent parent;





    private Gender gender;
    private LocalDateTime createdAt;
    private String name;
    private int age;


    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public int getChildId() {
        return ChildId;
    }

    public void setChildId(int childId) {
        ChildId = childId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public Gender getGender() {
        return gender;
    }

    public void setGender(Gender g) {
        this.gender = g;
    }



}
