package org.example.backend.controller;

import org.example.backend.Dto.aiReport.AIReportResponseDto;
import org.example.backend.Dto.aiReport.CreateAIReportDto;
import org.example.backend.Dto.aiReport.UpdateAIReportDto;
import org.example.backend.service.AIReportService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/ai-reports")
public class AIReportController {

    @Autowired
    private AIReportService aiReportService;

    @PostMapping
    public ResponseEntity<AIReportResponseDto> createReport(@RequestBody CreateAIReportDto dto) {
        var report = aiReportService.createReport(dto);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<AIReportResponseDto>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(aiReportService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AIReportResponseDto> getById(@PathVariable int id) {
        var report = aiReportService.getById(id);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<AIReportResponseDto>> getReportsByChild(@PathVariable int childId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(aiReportService.getReportsByChild(childId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AIReportResponseDto> updateReport(@PathVariable int id, @RequestBody UpdateAIReportDto dto) {
        var report = aiReportService.updateReport(id, dto);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReport(@PathVariable int id) {
        aiReportService.deleteReport(id);
        return ResponseEntity.noContent().build();
    }
    /**
     * GET /api/ai-reports/child/{childId}/version/{version}
     * Returns the AI report for a specific child at a specific version (e.g. v1, v2, v3)
     */
    @GetMapping("/child/{childId}/version/{version}")
    public ResponseEntity<AIReportResponseDto> getReportByVersion(
            @PathVariable int childId,
            @PathVariable String version) {
        var report = aiReportService.getReportByVersion(childId, version);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }
    /**
     * GET /api/ai-reports/child/{childId}/latest
     * Returns the most recent AI report for a child
     */
    @GetMapping("/child/{childId}/latest")
    public ResponseEntity<AIReportResponseDto> getLatestReport(@PathVariable int childId) {
        var report = aiReportService.getLatestReport(childId);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }
}