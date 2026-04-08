    package org.example.backend.model;

    import jakarta.persistence.*;
    import java.util.List;
    import static jakarta.persistence.GenerationType.IDENTITY;

    @Entity

    public class Parent {
        @Id
        @GeneratedValue(strategy = IDENTITY)
        private int ParentId;
        //@OneToMany
        //private List<Child> children;
    }
