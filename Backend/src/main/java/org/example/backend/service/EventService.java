package org.example.backend.service;

import org.example.backend.Dto.event.CreateActivityEventDto;
import org.example.backend.Dto.event.CreateChallengeEventDto;
import org.example.backend.Dto.event.CreateHelpEventDto;
import org.example.backend.Dto.event.CreateLevelEventDto;
import org.example.backend.model.event.*;
import org.example.backend.repo.event.*;
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

    // --- Generic queries ---
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
        event.setType(EventType.LEVEL);
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
        event.setType(EventType.CHALLENGE);
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createChallengeEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createChallengeEventDto.getSessionId()));
        event.setAction(createChallengeEventDto.getAction());
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
        event.setType(EventType.HELP);
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createHelpEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createHelpEventDto.getSessionId()));
        event.setHelpLevel(createHelpEventDto.getHelpLevel());
        return helpEventRepo.save(event);
    }

    public List<HelpEvent> getHelpEventsBySession(int sessionId) {
        return helpEventRepo.findBySessionId(sessionId);
    }

    public List<HelpEvent> getHelpEventsByChildAndLevel(int childId, HelpLevel helpLevel) {
        return helpEventRepo.findByChildIdAndHelpLevel(childId, helpLevel);
    }

    // --- ActivityEvent ---
    public ActivityEvent createActivityEvent(CreateActivityEventDto createActivityEventDto) {
        ActivityEvent event = new ActivityEvent();
        event.setType(EventType.ACTIVITY);
        event.setCreatedAt(LocalDateTime.now());
        event.setChild(childService.getChildById(createActivityEventDto.getChildId()));
        event.setSession(sessionService.getSessionById(createActivityEventDto.getSessionId()));
        event.setActivity(activityService.getActivityById(createActivityEventDto.getActivityId()));
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