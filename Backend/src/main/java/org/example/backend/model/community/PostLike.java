package org.example.backend.model.community;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.Child;
import org.example.backend.model.Parent;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "post_likes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PostLike {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "post_id")
    @JsonIgnore
    private Post post;

    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "parent_id")
    private Parent parent;
}
