package org.example.backend.service;

import org.example.backend.Dto.performance.CreatePerformanceDto;
import org.example.backend.Dto.performance.UpdatePerformanceDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.Child;
import org.example.backend.model.Performance;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.PerformanceRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PerformanceService {

    @Autowired
    private PerformanceRepo performanceRepo;

    @Autowired
    private ChildRepo childRepo;

    @Autowired
    private ActivityRepo activityRepo;

    public Performance createPerformance(CreatePerformanceDto dto) {
        Child child = childRepo.findById(dto.getChildId()).orElse(null);
        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);

        if (child == null || activity == null) return null;

        Performance performance = new Performance();
        performance.setCompletionScore(dto.getCompletionScore());
        performance.setEfficiencyScore(dto.getEfficiencyScore());
        performance.setPersistenceScore(dto.getPersistenceScore());
        performance.setIndependenceScore(dto.getIndependenceScore());
        performance.setStrategyScore(dto.getStrategyScore());
        performance.setLastUpdated(LocalDateTime.now());
        performance.setChild(child);
        performance.setActivity(activity);
        return performanceRepo.save(performance);
    }

    public List<Performance> getAll() {
        return performanceRepo.findAll();
    }

    public Performance getById(int id) {
        return performanceRepo.findById(id).orElse(null);
    }

    public List<Performance> getPerformanceByChild(int childId) {
        return performanceRepo.findByChildId(childId);
    }

    public List<Performance> getPerformanceByActivity(int activityId) {
        return performanceRepo.findByActivityId(activityId);
    }

    public Performance updatePerformance(int id, UpdatePerformanceDto dto) {
        Performance p = getById(id);
        if (p != null) {
            p.setCompletionScore(dto.getCompletionScore());
            p.setEfficiencyScore(dto.getEfficiencyScore());
            p.setPersistenceScore(dto.getPersistenceScore());
            p.setIndependenceScore(dto.getIndependenceScore());
            p.setStrategyScore(dto.getStrategyScore());
            p.setLastUpdated(LocalDateTime.now());
            return performanceRepo.save(p);
        }
        return null;
    }

    public void deletePerformance(int id) {
        performanceRepo.deleteById(id);
    }
}
