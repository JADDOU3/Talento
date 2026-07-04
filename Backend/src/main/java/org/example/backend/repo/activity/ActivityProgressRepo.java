package org.example.backend.repo.activity;

import org.example.backend.model.activity.ActivityProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ActivityProgressRepo extends JpaRepository<ActivityProgress, Integer> {
    Optional<ActivityProgress> findByChildIdAndActivityId(int childId, int activityId);
    int countByChildIdAndCompletedTrue(int childId);
    Optional<ActivityProgress> findTopByChildIdOrderByUpdatedAtDesc(int childId);
    Optional<ActivityProgress> findTopByChildIdAndUpdatedAtIsNotNullOrderByUpdatedAtDesc(int childId);
}