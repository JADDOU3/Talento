package org.example.backend.service;

import org.example.backend.Dto.activityPreference.CreateActivityPreferenceDto;
import org.example.backend.Dto.activityPreference.UpdateActivityPreferenceDto;
import org.example.backend.model.Activity;
import org.example.backend.model.ActivityPreference;
import org.example.backend.model.Child;
import org.example.backend.repo.ActivityPreferenceRepo;
import org.example.backend.repo.ActivityRepo;
import org.example.backend.repo.ChildRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivityPreferenceService {

    @Autowired
    private ActivityPreferenceRepo activityPreferenceRepo;

    @Autowired
    private ChildRepo childRepo;

    @Autowired
    private ActivityRepo activityRepo;

    public ActivityPreference createPreference(CreateActivityPreferenceDto dto) {
        Child child = childRepo.findById(dto.getChildId()).orElse(null);
        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);

        if (child == null || activity == null) return null;

        ActivityPreference preference = new ActivityPreference();
        preference.setTimesStarted(dto.getTimesStarted());
        preference.setTimesRepeated(dto.getTimesRepeated());
        preference.setTimesCompleted(dto.getTimesCompleted());
        preference.setLastPlayed(dto.getLastPlayed() != null ? dto.getLastPlayed() : LocalDateTime.now());
        preference.setChild(child);
        preference.setActivity(activity);
        return activityPreferenceRepo.save(preference);
    }

    public List<ActivityPreference> getAll() {
        return activityPreferenceRepo.findAll();
    }

    public ActivityPreference getById(int id) {
        return activityPreferenceRepo.findById(id).orElse(null);
    }

    public List<ActivityPreference> getPreferencesByChild(int childId) {
        return activityPreferenceRepo.findByChildId(childId);
    }

    public ActivityPreference getPreference(int childId, int activityId) {
        return activityPreferenceRepo.findByChildIdAndActivityId(childId, activityId);
    }

    public ActivityPreference updatePreference(int id, UpdateActivityPreferenceDto dto) {
        ActivityPreference p = getById(id);
        if (p != null) {
            p.setTimesStarted(dto.getTimesStarted());
            p.setTimesRepeated(dto.getTimesRepeated());
            p.setTimesCompleted(dto.getTimesCompleted());
            p.setLastPlayed(dto.getLastPlayed() != null ? dto.getLastPlayed() : LocalDateTime.now());
            return activityPreferenceRepo.save(p);
        }
        return null;
    }

    public void deletePreference(int id) {
        activityPreferenceRepo.deleteById(id);
    }
}
