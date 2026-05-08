package org.example.backend.controller;

import org.example.backend.Dto.performance.CreatePerformanceDto;
import org.example.backend.Dto.performance.UpdatePerformanceDto;
import org.example.backend.model.Performance;
import org.example.backend.service.PerformanceService;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<List<Performance>> getAll() {
        return ResponseEntity.ok(performanceService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Performance> getById(@PathVariable int id) {
        Performance p = performanceService.getById(id);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<Performance>> getPerformanceByChild(@PathVariable int childId) {
        return ResponseEntity.ok(performanceService.getPerformanceByChild(childId));
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<List<Performance>> getPerformanceByActivity(@PathVariable int activityId) {
        return ResponseEntity.ok(performanceService.getPerformanceByActivity(activityId));
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
