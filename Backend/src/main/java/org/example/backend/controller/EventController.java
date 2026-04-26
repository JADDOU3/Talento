package org.example.backend.controller;

import org.example.backend.model.*;
import org.example.backend.model.event.*;
import org.example.backend.service.EventService;
import org.example.backend.util.enums.*;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<List<Event>> getEventsByChild(@PathVariable int childId) {
        return new ResponseEntity<>(eventService.getEventsByChild(childId), HttpStatus.OK);
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<List<Event>> getEventsBySession(@PathVariable int sessionId) {
        return new ResponseEntity<>(eventService.getEventsBySession(sessionId), HttpStatus.OK);
    }

    @GetMapping("/child/{childId}/type/{type}")
    public ResponseEntity<List<Event>> getEventsByChildAndType(
            @PathVariable int childId, @PathVariable EventType type) {
        return new ResponseEntity<>(eventService.getEventsByChildAndType(childId, type), HttpStatus.OK);
    }

    // --- LevelEvent ---
    @PostMapping("/level")
    public ResponseEntity<LevelEvent> createLevelEvent(
            @RequestParam int childId,
            @RequestParam int sessionId,
            @RequestParam int activitySessionId,
            @RequestParam EventAction action) {
        return new ResponseEntity<>(
                eventService.createLevelEvent(childId, sessionId, activitySessionId, action),
                HttpStatus.CREATED);
    }

    @GetMapping("/level/session/{sessionId}")
    public ResponseEntity<List<LevelEvent>> getLevelEventsBySession(@PathVariable int sessionId) {
        return new ResponseEntity<>(eventService.getLevelEventsBySession(sessionId), HttpStatus.OK);
    }

    @GetMapping("/level/child/{childId}/action/{action}")
    public ResponseEntity<List<LevelEvent>> getLevelEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action) {
        return new ResponseEntity<>(eventService.getLevelEventsByChildAndAction(childId, action), HttpStatus.OK);
    }

    // --- ChallengeEvent ---
    @PostMapping("/challenge")
    public ResponseEntity<ChallengeEvent> createChallengeEvent(
            @RequestParam int childId,
            @RequestParam int sessionId,
            @RequestParam EventAction action) {
        return new ResponseEntity<>(
                eventService.createChallengeEvent(childId, sessionId, action),
                HttpStatus.CREATED);
    }

    @GetMapping("/challenge/session/{sessionId}")
    public ResponseEntity<List<ChallengeEvent>> getChallengeEventsBySession(@PathVariable int sessionId) {
        return new ResponseEntity<>(eventService.getChallengeEventsBySession(sessionId), HttpStatus.OK);
    }

    @GetMapping("/challenge/child/{childId}/action/{action}")
    public ResponseEntity<List<ChallengeEvent>> getChallengeEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action) {
        return new ResponseEntity<>(eventService.getChallengeEventsByChildAndAction(childId, action), HttpStatus.OK);
    }

    // --- HelpEvent ---
    @PostMapping("/help")
    public ResponseEntity<HelpEvent> createHelpEvent(
            @RequestParam int childId,
            @RequestParam int sessionId,
            @RequestParam HelpLevel helpLevel) {
        return new ResponseEntity<>(
                eventService.createHelpEvent(childId, sessionId, helpLevel),
                HttpStatus.CREATED);
    }

    @GetMapping("/help/session/{sessionId}")
    public ResponseEntity<List<HelpEvent>> getHelpEventsBySession(@PathVariable int sessionId) {
        return new ResponseEntity<>(eventService.getHelpEventsBySession(sessionId), HttpStatus.OK);
    }

    @GetMapping("/help/child/{childId}/level/{helpLevel}")
    public ResponseEntity<List<HelpEvent>> getHelpEventsByChildAndLevel(
            @PathVariable int childId, @PathVariable HelpLevel helpLevel) {
        return new ResponseEntity<>(eventService.getHelpEventsByChildAndLevel(childId, helpLevel), HttpStatus.OK);
    }

    // --- ActivityEvent ---
    @PostMapping("/activity")
    public ResponseEntity<ActivityEvent> createActivityEvent(
            @RequestParam int childId,
            @RequestParam int sessionId,
            @RequestParam int activityId,
            @RequestParam EventAction action) {
        return new ResponseEntity<>(
                eventService.createActivityEvent(childId, sessionId, activityId, action),
                HttpStatus.CREATED);
    }

    @GetMapping("/activity/session/{sessionId}")
    public ResponseEntity<List<ActivityEvent>> getActivityEventsBySession(@PathVariable int sessionId) {
        return new ResponseEntity<>(eventService.getActivityEventsBySession(sessionId), HttpStatus.OK);
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<List<ActivityEvent>> getActivityEventsByActivity(@PathVariable int activityId) {
        return new ResponseEntity<>(eventService.getActivityEventsByActivity(activityId), HttpStatus.OK);
    }
}