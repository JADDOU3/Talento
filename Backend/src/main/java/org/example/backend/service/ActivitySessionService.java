package org.example.backend.service;

import org.example.backend.Dto.activitySession.StartActivitySessionDto;
import org.example.backend.Dto.activitySession.UpdateActivitySessionDto;
import org.example.backend.model.Activity;
import org.example.backend.model.ActivitySession;
import org.example.backend.model.Session;
import org.example.backend.repo.ActivityRepo;
import org.example.backend.repo.ActivitySessionRepo;
import org.example.backend.repo.SessionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivitySessionService {

    @Autowired
    private ActivitySessionRepo activitySessionRepo;
    @Autowired
    private SessionService sessionService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private SessionRepo sessionRepo;
    @Autowired
    private ActivityRepo activityRepo;

    public ActivitySession createActivitySession(StartActivitySessionDto startActivitySessionDto) {
        ActivitySession activitySession = new ActivitySession();
        Session session = sessionService.getSessionById(startActivitySessionDto.getSessionId());
        Activity activity = activityService.getActivityById(startActivitySessionDto.getActivityId());

        activitySession.setOrderIndex(startActivitySessionDto.getOrderIndex());
        activitySession.setStartedAt(LocalDateTime.now());

        activitySession.setActivity(activity);
        activitySession.setSession(session);
        session.getActivitySessions().add(activitySession);
        activity.getActivitySessions().add(activitySession);

        sessionRepo.save(session);
        activityRepo.save(activity);
        return activitySessionRepo.save(activitySession);
    }

    public ActivitySession getActivitySessionById(int id) {
        return activitySessionRepo.findById(id).orElse(null);
    }

    public List<ActivitySession> getAllActivitySessionsBySession(int sessionId) {
        return activitySessionRepo.findBySessionId(sessionId);
    }

    public ActivitySession updateActivitySession(UpdateActivitySessionDto updateActivitySessionDto) {
        ActivitySession activitySession = getActivitySessionById(updateActivitySessionDto.getId());

        if(updateActivitySessionDto.getOrderIndex() != null) activitySession.setOrderIndex(updateActivitySessionDto.getOrderIndex());
        if(updateActivitySessionDto.getStartedAt() != null) activitySession.setStartedAt(updateActivitySessionDto.getStartedAt());
        if(updateActivitySessionDto.getEndedAt() != null) activitySession.setEndedAt(updateActivitySessionDto.getEndedAt());


        activitySession.setActivity(activityService.getActivityById(updateActivitySessionDto.getActivityId()));
        activitySession.setSession(sessionService.getSessionById(updateActivitySessionDto.getSessionId()));

        return activitySessionRepo.save(activitySession);
    }

    public void deleteActivitySession(int id) {
        ActivitySession activitySession = getActivitySessionById(id);
        activitySessionRepo.delete(activitySession);
    }

    public List<ActivitySession> getAllActivitySessions() {
        return activitySessionRepo.findAll();
    }

    public ActivitySession endActivitySession(int id) {
        ActivitySession activitySession = getActivitySessionById(id);
        activitySession.setEndedAt(LocalDateTime.now());
        return activitySessionRepo.save(activitySession);
    }
}