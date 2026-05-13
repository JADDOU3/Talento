package org.example.backend.repo;

import org.example.backend.model.Performance;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PerformanceRepo extends JpaRepository<Performance, Integer> {
    List<Performance> findByChildId(int childId);
    List<Performance> findByActivityId(int activityId);
}
