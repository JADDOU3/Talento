package org.example.backend.service;

import org.example.backend.Dto.aiReport.CreateAIReportDto;
import org.example.backend.Dto.aiReport.UpdateAIReportDto;
import org.example.backend.model.AIReport;
import org.example.backend.model.Child;
import org.example.backend.repo.AIReportRepo;
import org.example.backend.repo.ChildRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AIReportService {

    @Autowired
    private AIReportRepo aiReportRepo;

    @Autowired
    private ChildRepo childRepo;

    public AIReport createReport(CreateAIReportDto dto) {
        Child child = childRepo.findById(dto.getChildId()).orElse(null);
        if (child == null) return null;

        AIReport report = new AIReport();
        report.setSummary(dto.getSummary());
        report.setGeneratedAt(dto.getGeneratedAt() != null ? dto.getGeneratedAt() : LocalDateTime.now());
        report.setChild(child);
        return aiReportRepo.save(report);
    }

    public List<AIReport> getAll() {
        return aiReportRepo.findAll();
    }

    public AIReport getById(int id) {
        return aiReportRepo.findById(id).orElse(null);
    }

    public List<AIReport> getReportsByChild(int childId) {
        return aiReportRepo.findByChildId(childId);
    }

    public AIReport updateReport(int id, UpdateAIReportDto dto) {
        AIReport report = getById(id);
        if (report != null) {
            report.setSummary(dto.getSummary());
            report.setGeneratedAt(dto.getGeneratedAt() != null ? dto.getGeneratedAt() : LocalDateTime.now());
            return aiReportRepo.save(report);
        }
        return null;
    }

    public void deleteReport(int id) {
        aiReportRepo.deleteById(id);
    }
}
