package org.example.backend.service;

import org.example.backend.Dto.event.CreateActivityEventDto;
import org.example.backend.Dto.event.CreateChallengeEventDto;
import org.example.backend.Dto.event.CreateHelpEventDto;
import org.example.backend.Dto.event.CreateLevelEventDto;
import org.example.backend.model.event.*;
import org.example.backend.repo.event.*;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.util.enums.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class EventService {

    @Autowired private EventRepo eventRepo;
    @Autowired private LevelEventRepo levelEventRepo;
    @Autowired private ChallengeEventRepo challengeEventRepo;
    @Autowired private HelpEventRepo helpEventRepo;
    @Autowired private ActivityEventRepo activityEventRepo;
    @Autowired private ChildService childService;
    @Autowired private SessionService sessionService;
    @Autowired private ActivityService activityService;

    public List<Event> getEventsByChild(int childId) {
        return eventRepo.findByChildId(childId);
    }

    public List<Event> getEventsBySession(int sessionId) {
        return eventRepo.findBySessionId(sessionId);
    }

    public List<Event> getEventsByChildAndType(int childId, EventType type) {
        return eventRepo.findByChildIdAndType(childId, type);
    }

    // --- LevelEvent ---
    public LevelEvent createLevelEvent(CreateLevelEventDto createLevelEventDto) {
        LevelEvent event = new LevelEvent();
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createLevelEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createLevelEventDto.getSessionId()));
        event.setAction(createLevelEventDto.getAction());
        return levelEventRepo.save(event);
    }

    public List<LevelEvent> getLevelEventsBySession(int sessionId) {
        return levelEventRepo.findBySessionId(sessionId);
    }

    public List<LevelEvent> getLevelEventsByChildAndAction(int childId, EventAction action) {
        return levelEventRepo.findByChildIdAndAction(childId, action);
    }

    // --- ChallengeEvent ---
    public ChallengeEvent createChallengeEvent(CreateChallengeEventDto createChallengeEventDto) {
        ChallengeEvent event = new ChallengeEvent();
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createChallengeEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createChallengeEventDto.getSessionId()));
        event.setAction(createChallengeEventDto.getAction());
        if (createChallengeEventDto.getActivityId() != null) {
            event.setActivity(activityService.getRawActivityById(createChallengeEventDto.getActivityId()));
        }
        return challengeEventRepo.save(event);
    }

    public List<ChallengeEvent> getChallengeEventsBySession(int sessionId) {
        return challengeEventRepo.findBySessionId(sessionId);
    }

    public List<ChallengeEvent> getChallengeEventsByChildAndAction(int childId, EventAction action) {
        return challengeEventRepo.findByChildIdAndAction(childId, action);
    }

    // --- HelpEvent ---
    public HelpEvent createHelpEvent(CreateHelpEventDto createHelpEventDto) {
        HelpEvent event = new HelpEvent();
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createHelpEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createHelpEventDto.getSessionId()));
        event.setHelpLevel(createHelpEventDto.getHelpLevel());
        return helpEventRepo.save(event);
    }

    public List<HelpEvent> getHelpEventsBySession(int sessionId) {
        return helpEventRepo.findBySessionId(sessionId);
    }

    // --- ActivityEvent ---
    public ActivityEvent createActivityEvent(CreateActivityEventDto createActivityEventDto) {
        ActivityEvent event = new ActivityEvent();
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createActivityEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createActivityEventDto.getSessionId()));
        event.setActivity(activityService.getRawActivityById(createActivityEventDto.getActivityId()));
        event.setAction(createActivityEventDto.getAction());
        return activityEventRepo.save(event);
    }

    public List<ActivityEvent> getActivityEventsBySession(int sessionId) {
        return activityEventRepo.findBySessionId(sessionId);
    }

    public List<ActivityEvent> getActivityEventsByActivity(int activityId) {
        return activityEventRepo.findByActivityId(activityId);
    }
}