package org.example.backend.controller.activity;

import org.example.backend.Dto.activity.ActivityResponseDto;
import org.example.backend.Dto.activity.AssignActivityToKitDto;
import org.example.backend.Dto.activity.CreateActivityDto;
import org.example.backend.Dto.activity.UpdateActivityDto;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.KitService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/activities")
public class ActivityController {

    @Autowired
    private ActivityService activityService;
    @Autowired
    private KitService kitService;

    @PostMapping("/")
    public ResponseEntity<ActivityResponseDto> createActivity(@RequestBody CreateActivityDto dto) {
        return new ResponseEntity<>(activityService.createActivity(dto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityResponseDto> getActivityById(@PathVariable int id) {
        ActivityResponseDto activity = activityService.getActivityById(id);
        return activity != null ? ResponseEntity.ok(activity) : ResponseEntity.notFound().build();
    }

    @GetMapping("/")
    public ResponseEntity<Page<ActivityResponseDto>> getAllActivities(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(activityService.getAllActivities(), pageable));
    }

    @PutMapping("/")
    public ResponseEntity<ActivityResponseDto> updateActivity(@RequestBody UpdateActivityDto dto) {
        ActivityResponseDto activity = activityService.updateActivity(dto);
        return activity != null ? ResponseEntity.ok(activity) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteActivity(@PathVariable int id) {
        activityService.deleteActivity(id);
        return ResponseEntity.ok("Activity deleted successfully");
    }

    @PutMapping("/kit/")
    public ResponseEntity<ActivityResponseDto> assignActivityToKit(@RequestBody AssignActivityToKitDto dto) {
        if (activityService.getRawActivityById(dto.getActivityId()) == null)
            return ResponseEntity.notFound().build();
        if (kitService.getKitById(dto.getKitId()) == null)
            return ResponseEntity.notFound().build();
        return ResponseEntity.ok(activityService.assignActivityToKit(dto));
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<Page<ActivityResponseDto>> getAllActivitiesByKit(@PathVariable int kitId, Pageable pageable) {
        var activities = activityService.getActivitiesByKit(kitId);
        return activities != null
                ? ResponseEntity.ok(PaginationUtil.paginate(activities, pageable))
                : ResponseEntity.notFound().build();
    }
}