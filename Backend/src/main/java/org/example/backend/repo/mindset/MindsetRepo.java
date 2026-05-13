package org.example.backend.repo.mindset;

import org.example.backend.model.mindset.Mindset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MindsetRepo extends JpaRepository<Mindset, Integer> {
    Mindset findByName(String name);
}
