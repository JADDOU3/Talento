package org.example.backend.service.activity;

import org.example.backend.Dto.activity.AssignActivityToKitDto;
import org.example.backend.Dto.activity.CreateActivityDto;
import org.example.backend.Dto.activity.UpdateActivityDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.Kit;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.service.KitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityService {

    @Autowired
    private ActivityRepo activityRepo;
    @Autowired
    private KitService kitService;

    public Activity createActivity(CreateActivityDto createActivityDto) {
        Activity activity = new Activity();
        activity.setName(createActivityDto.getName());
        activity.setDescription(createActivityDto.getDescription());
        activity.setType(createActivityDto.getType());
        activity.setVoiceEnabled(createActivityDto.getVoiceEnabled());
        return activityRepo.save(activity);
    }

    public Activity getActivityById(int id) {
        return activityRepo.findById(id).orElse(null);
    }

    public List<Activity> getAllActivities() {
        return activityRepo.findAll();
    }

    public Activity updateActivity(UpdateActivityDto updateActivityDto) {
        Activity activity = activityRepo.findById(updateActivityDto.getId()).orElse(null);
        if (activity == null) return null;
        if (updateActivityDto.getName() != null) activity.setName(updateActivityDto.getName());
        if (updateActivityDto.getDescription() != null) activity.setDescription(updateActivityDto.getDescription());
        if (updateActivityDto.getType() != null) activity.setType(updateActivityDto.getType());
        if (updateActivityDto.getVoiceEnabled() != null) activity.setVoiceEnabled(updateActivityDto.getVoiceEnabled());
        return activityRepo.save(activity);
    }

    public void deleteActivity(int id) {
        activityRepo.deleteById(id);
    }

    public Activity assignActivityToKit(AssignActivityToKitDto dto) {
        Kit kit = kitService.getKitById(dto.getKitId());
        Activity activity = getActivityById(dto.getActivityId());
        activity.setKit(kit);
        return activityRepo.save(activity);
    }

    public List<Activity> getActivitiesByKit(int kitId) {
        return activityRepo.findByKitId(kitId);
    }
}