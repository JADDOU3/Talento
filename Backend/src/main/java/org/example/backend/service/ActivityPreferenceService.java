package org.example.backend.service;

import org.example.backend.model.ActivityPreference;
import org.example.backend.repo.ActivityPreferenceRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivityPreferenceService {

    @Autowired
    private ActivityPreferenceRepo activityPreferenceRepo;

    public ActivityPreference savePreference(ActivityPreference preference) {
        preference.setLastPlayed(LocalDateTime.now());
        return activityPreferenceRepo.save(preference);
    }

    public List<ActivityPreference> getPreferencesByChild(int childId) {
        return activityPreferenceRepo.findByChildId(childId);
    }

    public ActivityPreference getPreference(int childId, int activityId) {
        return activityPreferenceRepo.findByChildIdAndActivityId(childId, activityId);
    }
}
