package org.example.backend.controller;

import org.example.backend.Dto.level.LevelStorySubmissionResponseDto;
import org.example.backend.service.level.LevelStorySubmissionService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/story-submissions")
public class LevelStorySubmissionController {

    private final LevelStorySubmissionService levelStorySubmissionService;

    public LevelStorySubmissionController(LevelStorySubmissionService levelStorySubmissionService) {
        this.levelStorySubmissionService = levelStorySubmissionService;
    }


    @GetMapping("/by-activity/{activityId}")
    public ResponseEntity<List<LevelStorySubmissionResponseDto>> getByActivity(
            @PathVariable int activityId) {
        return ResponseEntity.ok(levelStorySubmissionService.getByActivity(activityId));
    }


    @GetMapping("/by-child/{childId}")
    public ResponseEntity<List<LevelStorySubmissionResponseDto>> getByChild(
            @PathVariable int childId) {
        return ResponseEntity.ok(levelStorySubmissionService.getByChild(childId));
    }


    @GetMapping("/by-activity/{activityId}/child/{childId}")
    public ResponseEntity<List<LevelStorySubmissionResponseDto>> getByActivityAndChild(
            @PathVariable int activityId,
            @PathVariable int childId) {
        return ResponseEntity.ok(levelStorySubmissionService.getByActivityAndChild(activityId, childId));
    }


    @GetMapping("/count/by-activity/{activityId}")
    public ResponseEntity<Map<String, Long>> countByActivity(@PathVariable int activityId) {
        return ResponseEntity.ok(Map.of("count", levelStorySubmissionService.countByActivity(activityId)));
    }


    @GetMapping("/count/by-child/{childId}")
    public ResponseEntity<Map<String, Long>> countByChild(@PathVariable int childId) {
        return ResponseEntity.ok(Map.of("count", levelStorySubmissionService.countByChild(childId)));
    }


    @GetMapping("/count/by-activity/{activityId}/child/{childId}")
    public ResponseEntity<Map<String, Long>> countByActivityAndChild(
            @PathVariable int activityId,
            @PathVariable int childId) {
        return ResponseEntity.ok(Map.of("count", levelStorySubmissionService.countByActivityAndChild(activityId, childId)));
    }
}