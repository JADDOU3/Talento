package org.example.backend.service.roadmap;

import org.example.backend.Dto.roadmap.RoadmapActivityDto;
import org.example.backend.Dto.roadmap.RoadmapResponseDto;
import org.example.backend.model.Kit;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivityProgress;
import org.example.backend.model.level.Level;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.activity.ActivityProgressRepo;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.level.LevelRepo;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class RoadmapService {

    private final ActivityRepo activityRepo;
    private final LevelRepo levelRepo;
    private final KitRepo kitRepo;
    private final ActivityProgressRepo activityProgressRepo;

    public RoadmapService(
            ActivityRepo activityRepo,
            LevelRepo levelRepo,
            KitRepo kitRepo,
            ActivityProgressRepo activityProgressRepo
    ) {
        this.activityRepo = activityRepo;
        this.levelRepo = levelRepo;
        this.kitRepo = kitRepo;
        this.activityProgressRepo = activityProgressRepo;
    }

    public RoadmapResponseDto getRoadmap(int kitId, int childId) {
        Kit kit = kitRepo.findById(kitId).orElse(null);
        if (kit == null) return null;

        List<Activity> activities = activityRepo.findByKitIdOrderById(kitId);
        List<RoadmapActivityDto> roadmapActivities = new ArrayList<>();
        boolean previousCompleted = true;

        for (int i = 0; i < activities.size(); i++) {
            Activity activity = activities.get(i);
            int totalLevels = levelRepo.countByActivityId(activity.getId());

            // Read directly from progress table — no session computation needed
            Optional<ActivityProgress> progressOpt = activityProgressRepo
                    .findByChildIdAndActivityId(childId, activity.getId());

            int currentLevelNumber = 1;
            int completedLevels = 0;
            boolean completed = false;

            if (progressOpt.isPresent()) {
                ActivityProgress progress = progressOpt.get();
                currentLevelNumber = progress.getCurrentLevelNumber();
                completedLevels = progress.getCompletedLevels();
                completed = progress.isCompleted(); // sticky — never false once true
            }


//            String status;
//            if (completed) {
//                status = "COMPLETED";
//            } else if (activitySession != null) {
//                status = "CURRENT";
//            } else if (i == 0 || previousCompleted) {
//                status = "CURRENT";
//            } else {
//                status = "LOCKED";
//            }

            //Todo bring back the correct implementation after testing phase
            String status;
            if (completed) {
                status = "COMPLETED";
            } else {
                status = "CURRENT";
            }

            roadmapActivities.add(new RoadmapActivityDto(
                    activity.getId(),
                    activity.getName(),
                    activity.getCoverImageKey(),
                    status,
                    currentLevelNumber,
                    totalLevels,
                    completedLevels
            ));

            previousCompleted = "COMPLETED".equals(status);
        }

        return new RoadmapResponseDto(
                kit.getId(),
                kit.getName(),
                kit.getImageURL(),
                roadmapActivities
        );
    }
}