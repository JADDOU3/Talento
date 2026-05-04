package org.example.backend.repo.activity;

import org.example.backend.model.activity.ActivityPreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityPreferenceRepo extends JpaRepository<ActivityPreference, Integer> {
    List<ActivityPreference> findByChildId(int childId);
    List<ActivityPreference> findByActivityId(int activityId);
    ActivityPreference findByChildIdAndActivityId(int childId, int activityId);
}
