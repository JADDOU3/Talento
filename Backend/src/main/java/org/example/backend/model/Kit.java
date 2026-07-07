package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.util.enums.Type;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.time.LocalDateTime;
import java.util.ArrayList;
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
    private String imageKey;

    private int rating;
    private int age;

    @ElementCollection
    @CollectionTable(name = "kit_items", joinColumns = @JoinColumn(name = "kit_id"))
    @Column(name = "item")
    private List<String> kitItems;

    @ElementCollection
    @CollectionTable(name = "kit_images", joinColumns = @JoinColumn(name = "kit_id"))
    @Column(name = "image_key")
    private List<String> imageKeys;

    @Enumerated(EnumType.STRING)
    private Type type;

    @ManyToOne
    @JoinColumn(name = "mindset_id")
    private Mindset mindset;

    @JsonIgnore
    @OneToMany(mappedBy = "kit")
    private List<Session> sessions;

    @JsonIgnore
    @OneToMany
    @JoinColumn(name = "kit_id")
    private List<Activity> activities;

    @JsonIgnore
    @OneToMany(mappedBy = "kit")
    private List<ChildKit> childKits;

    @JsonIgnore
    @OneToMany(mappedBy="kit")
    private List<Review> reviews;
    @JsonIgnore
    @OneToMany(mappedBy = "kit")
    private List<CartItem> cartItems = new ArrayList<>();
    @JsonIgnore
    @OneToMany(mappedBy="kit")
    private List<FavoriteKit> favorites;

}