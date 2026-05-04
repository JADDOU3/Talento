package org.example.backend.service;

import org.example.backend.model.AIReport;
import org.example.backend.repo.AIReportRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AIReportService {

    @Autowired
    private AIReportRepo aiReportRepo;

    public AIReport generateReport(AIReport report) {
        report.setGeneratedAt(LocalDateTime.now());
        return aiReportRepo.save(report);
    }

    public List<AIReport> getReportsByChild(int childId) {
        return aiReportRepo.findByChildId(childId);
    }
}
