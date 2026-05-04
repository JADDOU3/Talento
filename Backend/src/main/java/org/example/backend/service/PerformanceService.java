package org.example.backend.service;

import org.example.backend.model.Performance;
import org.example.backend.repo.PerformanceRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PerformanceService {

    @Autowired
    private PerformanceRepo performanceRepo;

    public Performance savePerformance(Performance performance) {
        performance.setLastUpdated(LocalDateTime.now());
        return performanceRepo.save(performance);
    }

    public List<Performance> getPerformanceByChild(int childId) {
        return performanceRepo.findByChildId(childId);
    }

    public List<Performance> getPerformanceByActivity(int activityId) {
        return performanceRepo.findByActivityId(activityId);
    }
}
