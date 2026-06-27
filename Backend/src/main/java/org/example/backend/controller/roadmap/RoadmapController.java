package org.example.backend.controller.roadmap;

import org.example.backend.Dto.progress.ActivityProgressResponseDto;
import org.example.backend.Dto.progress.CompletedActivitiesCountDto;
import org.example.backend.Dto.progress.LastActivityReachedDto;
import org.example.backend.Dto.roadmap.RoadmapResponseDto;
import org.example.backend.service.activity.ActivityProgressService;
import org.example.backend.service.roadmap.RoadmapService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/roadmap")
public class RoadmapController {

    private final RoadmapService roadmapService;
    private final ActivityProgressService activityProgressService;

    public RoadmapController(
            RoadmapService roadmapService,
            ActivityProgressService activityProgressService
    ) {
        this.roadmapService = roadmapService;
        this.activityProgressService = activityProgressService;
    }

    /**
     * GET /api/roadmap/kit/{kitId}/child/{childId}
     * Returns the full roadmap for a child in a kit.
     * Reads directly from activity_progress table — fast and session-independent.
     * COMPLETED status is sticky and never resets on replay.
     */
    @GetMapping("/kit/{kitId}/child/{childId}")
    public ResponseEntity<RoadmapResponseDto> getRoadmap(
            @PathVariable int kitId,
            @PathVariable int childId
    ) {
        RoadmapResponseDto roadmap = roadmapService.getRoadmap(kitId, childId);
        if (roadmap == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(roadmap);
    }

    /**
     * GET /api/roadmap/progress/{activityId}
     * Returns the current progress of the selected child for a given activity.
     * Child is inferred from the JWT token — no childId needed.
     *
     * Response:
     * {
     *   "activityId": 5,
     *   "currentLevelNumber": 3,
     *   "currentLevelId": 25,
     *   "completedLevels": 2,
     *   "totalLevels": 5,
     *   "completed": false,
     *   "updatedAt": "2026-06-08T12:00:00"
     * }
     */
    @GetMapping("/progress/{activityId}")
    public ResponseEntity<ActivityProgressResponseDto> getProgress(
            @PathVariable int activityId
    ) {
        ActivityProgressResponseDto progress = activityProgressService.getProgress(activityId);
        return ResponseEntity.ok(progress);
    }




    @GetMapping("/progress/completed-count")
    public ResponseEntity<CompletedActivitiesCountDto> getCompletedActivitiesCount() {
        return ResponseEntity.ok(
                activityProgressService.getCompletedActivitiesCount()
        );
    }


    @GetMapping("/progress/last-reached")
    public ResponseEntity<LastActivityReachedDto> getLastActivityReached() {
        LastActivityReachedDto result = activityProgressService.getLastActivityReached();
        return result != null
                ? ResponseEntity.ok(result)
                : ResponseEntity.notFound().build();
    }
}