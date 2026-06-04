package org.example.backend.service.activity;

import org.example.backend.Dto.activity.ActivityResponseDto;
import org.example.backend.Dto.activity.AssignActivityToKitDto;
import org.example.backend.Dto.activity.CreateActivityDto;
import org.example.backend.Dto.activity.UpdateActivityDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.Kit;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.service.KitService;
import org.example.backend.service.community.S3Service;
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
    private S3Service s3Service;

    public ActivityResponseDto createActivity(CreateActivityDto dto) {
        Activity activity = new Activity();
        activity.setName(dto.getName());
        activity.setDescription(dto.getDescription());
        activity.setGameDescription(dto.getGameDescription());
        activity.setCoverImageKey(dto.getCoverImageKey());
        activity.setType(dto.getType());
        activity.setVoiceEnabled(dto.getVoiceEnabled());
        return toResponseDto(activityRepo.save(activity));
    }

    public ActivityResponseDto getActivityById(int id) {
        return activityRepo.findById(id).map(this::toResponseDto).orElse(null);
    }

    public Activity getRawActivityById(int id) {
        return activityRepo.findById(id).orElse(null);
    }

    public List<ActivityResponseDto> getAllActivities() {
        return activityRepo.findAll().stream().map(this::toResponseDto).toList();
    }

    public ActivityResponseDto updateActivity(UpdateActivityDto dto) {
        Activity activity = activityRepo.findById(dto.getId()).orElse(null);
        if (activity == null) return null;
        if (dto.getName() != null) activity.setName(dto.getName());
        if (dto.getDescription() != null) activity.setDescription(dto.getDescription());
        if (dto.getGameDescription() != null) activity.setGameDescription(dto.getGameDescription());
        if (dto.getCoverImageKey() != null) activity.setCoverImageKey(dto.getCoverImageKey());
        if (dto.getType() != null) activity.setType(dto.getType());
        if (dto.getVoiceEnabled() != null) activity.setVoiceEnabled(dto.getVoiceEnabled());
        return toResponseDto(activityRepo.save(activity));
    }

    public void deleteActivity(int id) {
        activityRepo.deleteById(id);
    }

    public ActivityResponseDto assignActivityToKit(AssignActivityToKitDto dto) {
        Kit kit = kitService.getKitById(dto.getKitId());
        Activity activity = activityRepo.findById(dto.getActivityId()).orElseThrow();
        activity.setKit(kit);
        return toResponseDto(activityRepo.save(activity));
    }

    public List<ActivityResponseDto> getActivitiesByKit(int kitId) {
        return activityRepo.findByKitId(kitId).stream().map(this::toResponseDto).toList();
    }

    private ActivityResponseDto toResponseDto(Activity activity) {
        String url = (activity.getCoverImageKey() != null && !activity.getCoverImageKey().isEmpty())
                ? s3Service.generatePresignedUrl(activity.getCoverImageKey())
                : null;
        return new ActivityResponseDto(activity, url);
    }
}