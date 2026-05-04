package org.example.backend.repo;

import org.example.backend.model.ActivityCriteria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityCriteriaRepo extends JpaRepository<ActivityCriteria, Integer> {
    List<ActivityCriteria> findByActivityId(int activityId);
    List<ActivityCriteria> findByCriteriaId(int criteriaId);
}
