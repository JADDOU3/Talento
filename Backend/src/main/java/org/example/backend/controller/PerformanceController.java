package org.example.backend.controller;

import org.example.backend.Dto.performance.CreatePerformanceDto;
import org.example.backend.Dto.performance.UpdatePerformanceDto;
import org.example.backend.model.Performance;
import org.example.backend.service.PerformanceService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/performances")
public class PerformanceController {

    @Autowired
    private PerformanceService performanceService;

    @PostMapping
    public ResponseEntity<Performance> createPerformance(@RequestBody CreatePerformanceDto dto) {
        Performance p = performanceService.createPerformance(dto);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<Performance>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(performanceService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Performance> getById(@PathVariable int id) {
        Performance p = performanceService.getById(id);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<Performance>> getPerformanceByChild(@PathVariable int childId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(performanceService.getPerformanceByChild(childId), pageable));
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<Performance>> getPerformanceByActivity(@PathVariable int activityId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(performanceService.getPerformanceByActivity(activityId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Performance> updatePerformance(@PathVariable int id, @RequestBody UpdatePerformanceDto dto) {
        Performance p = performanceService.updatePerformance(id, dto);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePerformance(@PathVariable int id) {
        performanceService.deletePerformance(id);
        return ResponseEntity.noContent().build();
    }
}
