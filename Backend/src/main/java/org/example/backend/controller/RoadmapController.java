package org.example.backend.controller;

import org.example.backend.Dto.progress.ActivityProgressDto;
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
     * COMPLETED status is preserved even if the child replays the activity.
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
     * GET /api/roadmap/progress/{activitySessionId}
     * Returns the current level and challenge the child is at within an activity session.
     *
     * Response:
     * {
     *   "activityId": 5,
     *   "activitySessionId": 12,
     *   "currentLevelNumber": 3,
     *   "currentLevelId": 25,
     *   "totalLevels": 5,
     *   "completedLevels": 2,
     *   "lastChallengeIndex": 1,   // 0-based, last challenge reached in current level
     *   "activityCompleted": false  // true even during replay if ever completed before
     * }
     */
    @GetMapping("/progress/{activitySessionId}")
    public ResponseEntity<ActivityProgressDto> getProgress(
            @PathVariable int activitySessionId
    ) {
        ActivityProgressDto progress = activityProgressService.getProgress(activitySessionId);
        return ResponseEntity.ok(progress);
    }
}