package org.example.backend.repo;

import org.example.backend.model.Criteria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CriteriaRepo extends JpaRepository<Criteria, Integer> {
    List<Criteria> findByMindsetId(int mindsetId);
}
