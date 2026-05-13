package org.example.backend.service.activity;

import org.example.backend.Dto.activityCriteria.CreateActivityCriteriaDto;
import org.example.backend.Dto.activityCriteria.UpdateActivityCriteriaDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivityCriteria;
import org.example.backend.model.mindset.Criteria;
import org.example.backend.repo.activity.ActivityCriteriaRepo;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.mindset.CriteriaRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivityCriteriaService {

    @Autowired
    private ActivityCriteriaRepo activityCriteriaRepo;

    @Autowired
    private ActivityRepo activityRepo;

    @Autowired
    private CriteriaRepo criteriaRepo;

    public ActivityCriteria createActivityCriteria(CreateActivityCriteriaDto dto) {
        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);
        Criteria criteria = criteriaRepo.findById(dto.getCriteriaId()).orElse(null);

        if (activity == null || criteria == null) return null;

        ActivityCriteria activityCriteria = new ActivityCriteria();
        activityCriteria.setWeight(dto.getWeight());
        activityCriteria.setActivity(activity);
        activityCriteria.setCriteria(criteria);
        return activityCriteriaRepo.save(activityCriteria);
    }

    public List<ActivityCriteria> getAll() {
        return activityCriteriaRepo.findAll();
    }

    public ActivityCriteria getById(int id) {
        return activityCriteriaRepo.findById(id).orElse(null);
    }

    public List<ActivityCriteria> getByActivity(int activityId) {
        return activityCriteriaRepo.findByActivityId(activityId);
    }

    public List<ActivityCriteria> getByCriteria(int criteriaId) {
        return activityCriteriaRepo.findByCriteriaId(criteriaId);
    }

    public ActivityCriteria updateActivityCriteria(int id, UpdateActivityCriteriaDto dto) {
        ActivityCriteria ac = getById(id);
        if (ac != null) {
            ac.setWeight(dto.getWeight());
            return activityCriteriaRepo.save(ac);
        }
        return null;
    }

    public void deleteActivityCriteria(int id) {
        activityCriteriaRepo.deleteById(id);
    }
}
