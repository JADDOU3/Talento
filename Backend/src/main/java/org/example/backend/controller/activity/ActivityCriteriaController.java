package org.example.backend.controller.activity;

import org.example.backend.Dto.activityCriteria.CreateActivityCriteriaDto;
import org.example.backend.Dto.activityCriteria.UpdateActivityCriteriaDto;
import org.example.backend.model.activity.ActivityCriteria;
import org.example.backend.service.activity.ActivityCriteriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/activity-criteria")
public class ActivityCriteriaController {

    @Autowired
    private ActivityCriteriaService activityCriteriaService;

    @PostMapping
    public ResponseEntity<ActivityCriteria> createActivityCriteria(@RequestBody CreateActivityCriteriaDto dto) {
        ActivityCriteria ac = activityCriteriaService.createActivityCriteria(dto);
        return ac != null ? ResponseEntity.ok(ac) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<List<ActivityCriteria>> getAll() {
        return ResponseEntity.ok(activityCriteriaService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityCriteria> getById(@PathVariable int id) {
        ActivityCriteria ac = activityCriteriaService.getById(id);
        return ac != null ? ResponseEntity.ok(ac) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<List<ActivityCriteria>> getByActivity(@PathVariable int activityId) {
        return ResponseEntity.ok(activityCriteriaService.getByActivity(activityId));
    }

    @GetMapping("/criteria/{criteriaId}")
    public ResponseEntity<List<ActivityCriteria>> getByCriteria(@PathVariable int criteriaId) {
        return ResponseEntity.ok(activityCriteriaService.getByCriteria(criteriaId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ActivityCriteria> updateActivityCriteria(@PathVariable int id, @RequestBody UpdateActivityCriteriaDto dto) {
        ActivityCriteria ac = activityCriteriaService.updateActivityCriteria(id, dto);
        return ac != null ? ResponseEntity.ok(ac) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteActivityCriteria(@PathVariable int id) {
        activityCriteriaService.deleteActivityCriteria(id);
        return ResponseEntity.noContent().build();
    }
}
