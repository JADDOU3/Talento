package org.example.backend.controller.activity;

import org.example.backend.Dto.activity.ActivityCriteriaResponseDto;
import org.example.backend.Dto.activityCriteria.CreateActivityCriteriaDto;
import org.example.backend.Dto.activityCriteria.UpdateActivityCriteriaDto;
import org.example.backend.service.activity.ActivityCriteriaService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/activity-criteria")
public class ActivityCriteriaController {

    @Autowired
    private ActivityCriteriaService activityCriteriaService;

    @PostMapping
    public ResponseEntity<ActivityCriteriaResponseDto> createActivityCriteria(@RequestBody CreateActivityCriteriaDto dto) {
        var ac = activityCriteriaService.createActivityCriteria(dto);
        return ac != null ? ResponseEntity.ok(ActivityCriteriaResponseDto.from(ac)) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<ActivityCriteriaResponseDto>> getAll(Pageable pageable) {
        var dtos = activityCriteriaService.getAll().stream().map(ActivityCriteriaResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityCriteriaResponseDto> getById(@PathVariable int id) {
        var ac = activityCriteriaService.getById(id);
        return ac != null ? ResponseEntity.ok(ActivityCriteriaResponseDto.from(ac)) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<ActivityCriteriaResponseDto>> getByActivity(@PathVariable int activityId, Pageable pageable) {
        var dtos = activityCriteriaService.getByActivity(activityId).stream().map(ActivityCriteriaResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/criteria/{criteriaId}")
    public ResponseEntity<Page<ActivityCriteriaResponseDto>> getByCriteria(@PathVariable int criteriaId, Pageable pageable) {
        var dtos = activityCriteriaService.getByCriteria(criteriaId).stream().map(ActivityCriteriaResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ActivityCriteriaResponseDto> updateActivityCriteria(@PathVariable int id, @RequestBody UpdateActivityCriteriaDto dto) {
        var ac = activityCriteriaService.updateActivityCriteria(id, dto);
        return ac != null ? ResponseEntity.ok(ActivityCriteriaResponseDto.from(ac)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteActivityCriteria(@PathVariable int id) {
        activityCriteriaService.deleteActivityCriteria(id);
        return ResponseEntity.noContent().build();
    }
}
