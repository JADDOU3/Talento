package org.example.backend.controller;

import org.example.backend.Dto.aiReport.CreateAIReportDto;
import org.example.backend.Dto.aiReport.UpdateAIReportDto;
import org.example.backend.model.AIReport;
import org.example.backend.service.AIReportService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ai-reports")
public class AIReportController {

    @Autowired
    private AIReportService aiReportService;

    @PostMapping
    public ResponseEntity<AIReport> createReport(@RequestBody CreateAIReportDto dto) {
        AIReport report = aiReportService.createReport(dto);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<AIReport>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(aiReportService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<AIReport> getById(@PathVariable int id) {
        AIReport report = aiReportService.getById(id);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<AIReport>> getReportsByChild(@PathVariable int childId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(aiReportService.getReportsByChild(childId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AIReport> updateReport(@PathVariable int id, @RequestBody UpdateAIReportDto dto) {
        AIReport report = aiReportService.updateReport(id, dto);
        return report != null ? ResponseEntity.ok(report) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReport(@PathVariable int id) {
        aiReportService.deleteReport(id);
        return ResponseEntity.noContent().build();
    }
}
