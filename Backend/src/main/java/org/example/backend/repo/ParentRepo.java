package org.example.backend.repo;

import org.example.backend.model.Parent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ParentRepo extends JpaRepository<Parent, Integer> {

    Parent findByEmail(String email);
}
