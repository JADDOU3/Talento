package org.example.backend.service;

import org.example.backend.Dto.aiReport.AIReportResponseDto;
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

    public AIReportResponseDto createReport(CreateAIReportDto dto) {
        Child child = childRepo.findById(dto.getChildId()).orElse(null);
        if (child == null) return null;

        AIReport report = new AIReport();
        report.setSummary(dto.getSummary());
        report.setGeneratedAt(dto.getGeneratedAt() != null ? dto.getGeneratedAt() : LocalDateTime.now());
        report.setChild(child);
        return AIReportResponseDto.from(aiReportRepo.save(report));
    }

    public List<AIReportResponseDto> getAll() {
        return aiReportRepo.findAll().stream()
                .map(AIReportResponseDto::from)
                .toList();
    }

    public AIReportResponseDto getById(int id) {
        return aiReportRepo.findById(id)
                .map(AIReportResponseDto::from)
                .orElse(null);
    }

    public List<AIReportResponseDto> getReportsByChild(int childId) {
        return aiReportRepo.findByChildId(childId).stream()
                .map(AIReportResponseDto::from)
                .toList();
    }

    public AIReportResponseDto updateReport(int id, UpdateAIReportDto dto) {
        AIReport report = aiReportRepo.findById(id).orElse(null);
        if (report == null) return null;
        report.setSummary(dto.getSummary());
        report.setGeneratedAt(dto.getGeneratedAt() != null ? dto.getGeneratedAt() : LocalDateTime.now());
        return AIReportResponseDto.from(aiReportRepo.save(report));
    }

    public void deleteReport(int id) {
        aiReportRepo.deleteById(id);
    }
}