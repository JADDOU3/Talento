package org.example.backend.controller;

import org.example.backend.Dto.event.CreateActivityEventDto;
import org.example.backend.Dto.event.CreateChallengeEventDto;
import org.example.backend.Dto.event.CreateHelpEventDto;
import org.example.backend.Dto.event.CreateLevelEventDto;
import org.example.backend.model.event.*;
import org.example.backend.service.EventService;
import org.example.backend.util.PaginationUtil;
import org.example.backend.util.enums.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/events")
public class EventController {

    @Autowired
    private EventService eventService;

    // --- Generic ---
    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<Event>> getEventsByChild(@PathVariable int childId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getEventsByChild(childId), pageable), HttpStatus.OK);
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<Page<Event>> getEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getEventsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @GetMapping("/child/{childId}/type/{type}")
    public ResponseEntity<Page<Event>> getEventsByChildAndType(
            @PathVariable int childId, @PathVariable EventType type, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getEventsByChildAndType(childId, type), pageable), HttpStatus.OK);
    }

    // --- LevelEvent ---
    @PostMapping("/level")
    public ResponseEntity<LevelEvent> createLevelEvent(@RequestBody CreateLevelEventDto createLevelEventDto) {
        return new ResponseEntity<>(eventService.createLevelEvent(createLevelEventDto), HttpStatus.CREATED);
    }

    @GetMapping("/level/session/{sessionId}")
    public ResponseEntity<Page<LevelEvent>> getLevelEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getLevelEventsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @GetMapping("/level/child/{childId}/action/{action}")
    public ResponseEntity<Page<LevelEvent>> getLevelEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getLevelEventsByChildAndAction(childId, action), pageable), HttpStatus.OK);
    }

    // --- ChallengeEvent ---
    @PostMapping("/challenge")
    public ResponseEntity<ChallengeEvent> createChallengeEvent(@RequestBody CreateChallengeEventDto createChallengeEventDto) {
        return new ResponseEntity<>(eventService.createChallengeEvent(createChallengeEventDto), HttpStatus.CREATED);
    }

    @GetMapping("/challenge/session/{sessionId}")
    public ResponseEntity<Page<ChallengeEvent>> getChallengeEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getChallengeEventsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @GetMapping("/challenge/child/{childId}/action/{action}")
    public ResponseEntity<Page<ChallengeEvent>> getChallengeEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getChallengeEventsByChildAndAction(childId, action), pageable), HttpStatus.OK);
    }

    // --- HelpEvent ---
    @PostMapping("/help")
    public ResponseEntity<HelpEvent> createHelpEvent(@RequestBody CreateHelpEventDto createHelpEventDto) {
        return new ResponseEntity<>(eventService.createHelpEvent(createHelpEventDto), HttpStatus.CREATED);
    }

    @GetMapping("/help/session/{sessionId}")
    public ResponseEntity<Page<HelpEvent>> getHelpEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getHelpEventsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @GetMapping("/help/child/{childId}/level/{helpLevel}")
    public ResponseEntity<Page<HelpEvent>> getHelpEventsByChildAndLevel(
            @PathVariable int childId, @PathVariable HelpLevel helpLevel, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getHelpEventsByChildAndLevel(childId, helpLevel), pageable), HttpStatus.OK);
    }

    // --- ActivityEvent ---
    @PostMapping("/activity")
    public ResponseEntity<ActivityEvent> createActivityEvent(@RequestBody CreateActivityEventDto createActivityEventDto) {
        return new ResponseEntity<>(
                eventService.createActivityEvent(createActivityEventDto),
                HttpStatus.CREATED);
    }

    @GetMapping("/activity/session/{sessionId}")
    public ResponseEntity<Page<ActivityEvent>> getActivityEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getActivityEventsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<ActivityEvent>> getActivityEventsByActivity(@PathVariable int activityId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(eventService.getActivityEventsByActivity(activityId), pageable), HttpStatus.OK);
    }
}