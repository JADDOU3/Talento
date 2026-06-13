package org.example.backend.controller;

import org.example.backend.Dto.performance.CreatePerformanceDto;
import org.example.backend.Dto.performance.PerformanceResponseDto;
import org.example.backend.Dto.performance.UpdatePerformanceDto;
import org.example.backend.service.PerformanceService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/performance")
public class PerformanceController {

    @Autowired
    private PerformanceService performanceService;

    @PostMapping
    public ResponseEntity<PerformanceResponseDto> createPerformance(@RequestBody CreatePerformanceDto dto) {
        var p = performanceService.createPerformance(dto);
        return p != null ? ResponseEntity.ok(PerformanceResponseDto.from(p)) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<PerformanceResponseDto>> getAll(Pageable pageable) {
        var dtos = performanceService.getAll().stream().map(PerformanceResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PerformanceResponseDto> getById(@PathVariable int id) {
        var p = performanceService.getById(id);
        return p != null ? ResponseEntity.ok(PerformanceResponseDto.from(p)) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<PerformanceResponseDto>> getPerformanceByChild(@PathVariable int childId, Pageable pageable) {
        var dtos = performanceService.getPerformanceByChild(childId).stream().map(PerformanceResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<PerformanceResponseDto>> getPerformanceByActivity(@PathVariable int activityId, Pageable pageable) {
        var dtos = performanceService.getPerformanceByActivity(activityId).stream().map(PerformanceResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PerformanceResponseDto> updatePerformance(@PathVariable int id, @RequestBody UpdatePerformanceDto dto) {
        var p = performanceService.updatePerformance(id, dto);
        return p != null ? ResponseEntity.ok(PerformanceResponseDto.from(p)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePerformance(@PathVariable int id) {
        performanceService.deletePerformance(id);
        return ResponseEntity.noContent().build();
    }
}
