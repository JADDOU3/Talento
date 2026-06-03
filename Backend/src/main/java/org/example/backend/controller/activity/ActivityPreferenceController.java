package org.example.backend.controller.activity;

import org.example.backend.Dto.activity.ActivityPreferenceResponseDto;
import org.example.backend.Dto.activityPreference.CreateActivityPreferenceDto;
import org.example.backend.Dto.activityPreference.UpdateActivityPreferenceDto;
import org.example.backend.service.activity.ActivityPreferenceService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/activity-preferences")
public class ActivityPreferenceController {

    @Autowired
    private ActivityPreferenceService activityPreferenceService;

    @PostMapping
    public ResponseEntity<ActivityPreferenceResponseDto> createPreference(@RequestBody CreateActivityPreferenceDto dto) {
        var p = activityPreferenceService.createPreference(dto);
        return p != null ? ResponseEntity.ok(ActivityPreferenceResponseDto.from(p)) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<ActivityPreferenceResponseDto>> getAll(Pageable pageable) {
        var dtos = activityPreferenceService.getAll().stream().map(ActivityPreferenceResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivityPreferenceResponseDto> getById(@PathVariable int id) {
        var p = activityPreferenceService.getById(id);
        return p != null ? ResponseEntity.ok(ActivityPreferenceResponseDto.from(p)) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<ActivityPreferenceResponseDto>> getPreferencesByChild(@PathVariable int childId, Pageable pageable) {
        var dtos = activityPreferenceService.getPreferencesByChild(childId).stream().map(ActivityPreferenceResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/child/{childId}/activity/{activityId}")
    public ResponseEntity<ActivityPreferenceResponseDto> getPreference(@PathVariable int childId, @PathVariable int activityId) {
        var p = activityPreferenceService.getPreference(childId, activityId);
        return p != null ? ResponseEntity.ok(ActivityPreferenceResponseDto.from(p)) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<ActivityPreferenceResponseDto> updatePreference(@PathVariable int id, @RequestBody UpdateActivityPreferenceDto dto) {
        var p = activityPreferenceService.updatePreference(id, dto);
        return p != null ? ResponseEntity.ok(ActivityPreferenceResponseDto.from(p)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePreference(@PathVariable int id) {
        activityPreferenceService.deletePreference(id);
        return ResponseEntity.noContent().build();
    }
}
