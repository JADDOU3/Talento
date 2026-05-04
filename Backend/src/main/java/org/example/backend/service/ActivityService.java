package org.example.backend.service;


import org.example.backend.Dto.CreateActivityDto;
import org.example.backend.Dto.UpdateActivityDto;
import org.example.backend.model.Activity;
import org.example.backend.repo.ActivityRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityService {

    @Autowired
    private ActivityRepo activityRepo;

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
}
