package org.example.backend.controller.activity;

import org.example.backend.Dto.activityCriteria.CreateActivityCriteriaDto;
import org.example.backend.Dto.activityCriteria.UpdateActivityCriteriaDto;
import org.example.backend.model.activity.ActivityCriteria;
import org.example.backend.service.activity.ActivityCriteriaService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
    public ResponseEntity<Page<ActivityCriteria>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(activityCriteriaService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityCriteria> getById(@PathVariable int id) {
        ActivityCriteria ac = activityCriteriaService.getById(id);
        return ac != null ? ResponseEntity.ok(ac) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<ActivityCriteria>> getByActivity(@PathVariable int activityId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(activityCriteriaService.getByActivity(activityId), pageable));
    }

    @GetMapping("/criteria/{criteriaId}")
    public ResponseEntity<Page<ActivityCriteria>> getByCriteria(@PathVariable int criteriaId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(activityCriteriaService.getByCriteria(criteriaId), pageable));
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
