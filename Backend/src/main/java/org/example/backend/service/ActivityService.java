package org.example.backend.service;


import org.example.backend.Dto.activity.AssignActivityToKitDto;
import org.example.backend.Dto.activity.CreateActivityDto;
import org.example.backend.Dto.activity.UpdateActivityDto;
import org.example.backend.model.Activity;
import org.example.backend.model.Kit;
import org.example.backend.repo.ActivityRepo;
import org.example.backend.repo.KitRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityService {

    @Autowired
    private ActivityRepo activityRepo;
    @Autowired
    private KitService kitService;
    @Autowired
    private KitRepo kitRepo;

    public Activity createActivity(CreateActivityDto createActivityDto){
        Activity activity = new Activity();
        activity.setName(createActivityDto.getName());
        activity.setDescription(createActivityDto.getDescription());
        activity.setType(createActivityDto.getType());

        return activityRepo.save(activity);
    }

    public Activity getActivityById(int id){
        return activityRepo.findById(id).orElse(null);
    }

    public List<Activity> getAllActivities(){
        return activityRepo.findAll();
    }

    public Activity updateActivity(UpdateActivityDto updateActivityDto){
        Activity activity = activityRepo.findById(updateActivityDto.getId()).orElse(null);
        if(activity == null){
            return null;
        }
        if(updateActivityDto.getName() != null) activity.setName(updateActivityDto.getName());
        if(updateActivityDto.getDescription() != null) activity.setDescription(updateActivityDto.getDescription());
        if(updateActivityDto.getType() != null) activity.setType(updateActivityDto.getType());

        return activityRepo.save(activity);
    }

    public void deleteActivity(int id){
        activityRepo.deleteById(id);
    }

    public Activity assignActivityToKit(AssignActivityToKitDto assignActivityToKitDto) {
        Kit kit = kitService.getKitById(assignActivityToKitDto.getKitId());
        Activity activity = getActivityById(assignActivityToKitDto.getActivityId());
        activity.setKit(kit);
        kit.getActivities().add(activity);
        kitRepo.save(kit);
        return activityRepo.save(activity);
    }

    public List<Activity> getActivitiesByKit(int kitId) {
        Kit kit = kitService.getKitById(kitId);
        return kit.getActivities();
    }
}