package org.example.backend.service.activity;

import org.example.backend.Dto.activitySession.StartActivitySessionDto;
import org.example.backend.Dto.activitySession.UpdateActivitySessionDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.Session;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.SessionRepo;
import org.example.backend.service.SessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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

    @Transactional
    public ActivitySession createActivitySession(StartActivitySessionDto startActivitySessionDto) {
        Session session = sessionRepo.findById(startActivitySessionDto.getSessionId())
                .orElseThrow(() -> new RuntimeException("Session not found"));
        Activity activity = activityRepo.findById(startActivitySessionDto.getActivityId())
                .orElseThrow(() -> new RuntimeException("Activity not found"));

        ActivitySession activitySession = new ActivitySession();
        activitySession.setOrderIndex(startActivitySessionDto.getOrderIndex());
        activitySession.setStartedAt(LocalDateTime.now());
        activitySession.setActivity(activity);
        activitySession.setSession(session);

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


        activitySession.setActivity(activityService.getRawActivityById(updateActivitySessionDto.getActivityId()));
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