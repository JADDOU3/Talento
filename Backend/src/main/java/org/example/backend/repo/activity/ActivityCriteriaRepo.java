package org.example.backend.repo.activity;

import org.example.backend.model.activity.ActivityCriteria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityCriteriaRepo extends JpaRepository<ActivityCriteria, Integer> {
    List<ActivityCriteria> findByActivityId(int activityId);
    List<ActivityCriteria> findByCriteriaId(int criteriaId);
}
