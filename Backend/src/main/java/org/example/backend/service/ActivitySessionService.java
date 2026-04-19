package org.example.backend.service;

import org.example.backend.Dto.ActivitySessionDto;
import org.example.backend.model.Activity;
import org.example.backend.model.ActivitySession;
import org.example.backend.model.Session;
import org.example.backend.repo.ActivitySessionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ActivitySessionService {

    @Autowired
    private ActivitySessionRepo activitySessionRepo;

    public ActivitySession createActivitySession(ActivitySessionDto d) {
        ActivitySession activitySession = new ActivitySession();
        Session session = new Session();

        activitySession.setOrderIndex(d.getOrderIndex());
        activitySession.setStartedAt(d.getStartedAt());
        activitySession.setEndedAt(d.getEndedAt());

        session.setId(d.getSessionId());
        activitySession.setSession(session);

         Activity activity = new Activity();
         activity.setId(d.getActivityId());
         activitySession.setActivity(activity);

        return activitySessionRepo.save(activitySession);
    }

    public ActivitySession getActivitySessionById(int id) {
        return activitySessionRepo.findById(id).orElse(null);
    }

    public List<ActivitySession> getAllActivitySessionsBySession(int sessionId) {
        return activitySessionRepo.findBySessionId(sessionId);
    }

    public ActivitySession updateActivitySession(int id, ActivitySessionDto d) {
        ActivitySession oldActivitySession = getActivitySessionById(id);

        if (oldActivitySession == null)
            return null;

        oldActivitySession.setOrderIndex(d.getOrderIndex());
        oldActivitySession.setStartedAt(d.getStartedAt());
        oldActivitySession.setEndedAt(d.getEndedAt());

        return activitySessionRepo.save(oldActivitySession);
    }

    public void deleteActivitySession(int id) {
        ActivitySession activitySession = getActivitySessionById(id);
        activitySessionRepo.delete(activitySession);
    }
}