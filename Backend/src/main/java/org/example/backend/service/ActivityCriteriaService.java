package org.example.backend.service;

import org.example.backend.model.ActivityCriteria;
import org.example.backend.repo.ActivityCriteriaRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityCriteriaService {

    @Autowired
    private ActivityCriteriaRepo activityCriteriaRepo;

    public ActivityCriteria saveActivityCriteria(ActivityCriteria activityCriteria) {
        return activityCriteriaRepo.save(activityCriteria);
    }

    public List<ActivityCriteria> getByActivity(int activityId) {
        return activityCriteriaRepo.findByActivityId(activityId);
    }

    public List<ActivityCriteria> getByCriteria(int criteriaId) {
        return activityCriteriaRepo.findByCriteriaId(criteriaId);
    }
}
