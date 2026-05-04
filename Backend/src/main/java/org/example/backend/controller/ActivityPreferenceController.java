package org.example.backend.controller;

import org.example.backend.Dto.activityPreference.CreateActivityPreferenceDto;
import org.example.backend.Dto.activityPreference.UpdateActivityPreferenceDto;
import org.example.backend.model.ActivityPreference;
import org.example.backend.service.ActivityPreferenceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/activity-preferences")
public class ActivityPreferenceController {

    @Autowired
    private ActivityPreferenceService activityPreferenceService;

    @PostMapping
    public ResponseEntity<ActivityPreference> createPreference(@RequestBody CreateActivityPreferenceDto dto) {
        ActivityPreference p = activityPreferenceService.createPreference(dto);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<List<ActivityPreference>> getAll() {
        return ResponseEntity.ok(activityPreferenceService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityPreference> getById(@PathVariable int id) {
        ActivityPreference p = activityPreferenceService.getById(id);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<ActivityPreference>> getPreferencesByChild(@PathVariable int childId) {
        return ResponseEntity.ok(activityPreferenceService.getPreferencesByChild(childId));
    }

    @GetMapping("/child/{childId}/activity/{activityId}")
    public ResponseEntity<ActivityPreference> getPreference(@PathVariable int childId, @PathVariable int activityId) {
        ActivityPreference p = activityPreferenceService.getPreference(childId, activityId);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<ActivityPreference> updatePreference(@PathVariable int id, @RequestBody UpdateActivityPreferenceDto dto) {
        ActivityPreference p = activityPreferenceService.updatePreference(id, dto);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePreference(@PathVariable int id) {
        activityPreferenceService.deletePreference(id);
        return ResponseEntity.noContent().build();
    }
}
