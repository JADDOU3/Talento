package org.example.backend.controller;

import org.example.backend.Dto.ActivitySessionDto;
import org.example.backend.model.ActivitySession;
import org.example.backend.service.ActivitySessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/activity-sessions")
public class ActivitySessionController {

    @Autowired
    private ActivitySessionService activitySessionService;

    @PostMapping
    public ActivitySession createActivitySession(@RequestBody ActivitySessionDto dto) {
        return activitySessionService.createActivitySession(dto);
    }

    @GetMapping("/{id}")
    public ActivitySession getActivitySessionById(@PathVariable int id) {
        return activitySessionService.getActivitySessionById(id);
    }

    @GetMapping("/session/{sessionId}")
    public List<ActivitySession> getAllActivitySessionsBySession(@PathVariable int sessionId) {
        return activitySessionService.getAllActivitySessionsBySession(sessionId);
    }

    @PutMapping("/{id}")
    public ActivitySession updateActivitySession(@PathVariable int id, @RequestBody ActivitySessionDto dto) {
        return activitySessionService.updateActivitySession(id, dto);
    }

    @DeleteMapping("/{id}")
    public void deleteActivitySession(@PathVariable int id) {
        activitySessionService.deleteActivitySession(id);
    }
}