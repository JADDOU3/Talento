package org.example.backend.repo.mindset;

import org.example.backend.model.mindset.Criteria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CriteriaRepo extends JpaRepository<Criteria, Integer> {
    List<Criteria> findByMindsetId(int mindsetId);
}
