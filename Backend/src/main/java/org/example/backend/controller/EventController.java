package org.example.backend.controller;

import org.example.backend.Dto.event.CreateActivityEventDto;
import org.example.backend.Dto.event.CreateChallengeEventDto;
import org.example.backend.Dto.event.CreateHelpEventDto;
import org.example.backend.Dto.event.CreateLevelEventDto;
import org.example.backend.Dto.event.EventResponseDto;
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

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<EventResponseDto>> getEventsByChild(@PathVariable int childId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getEventsByChild(childId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<Page<EventResponseDto>> getEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getEventsBySession(sessionId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/child/{childId}/type/{type}")
    public ResponseEntity<Page<EventResponseDto>> getEventsByChildAndType(
            @PathVariable int childId, @PathVariable EventType type, Pageable pageable) {
        List<EventResponseDto> events = eventService.getEventsByChildAndType(childId, type).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @PostMapping("/level")
    public ResponseEntity<EventResponseDto> createLevelEvent(@RequestBody CreateLevelEventDto createLevelEventDto) {
        return new ResponseEntity<>(EventResponseDto.from(eventService.createLevelEvent(createLevelEventDto)), HttpStatus.CREATED);
    }

    @GetMapping("/level/session/{sessionId}")
    public ResponseEntity<Page<EventResponseDto>> getLevelEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getLevelEventsBySession(sessionId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/level/child/{childId}/action/{action}")
    public ResponseEntity<Page<EventResponseDto>> getLevelEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action, Pageable pageable) {
        List<EventResponseDto> events = eventService.getLevelEventsByChildAndAction(childId, action).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @PostMapping("/challenge")
    public ResponseEntity<EventResponseDto> createChallengeEvent(@RequestBody CreateChallengeEventDto createChallengeEventDto) {
        return new ResponseEntity<>(EventResponseDto.from(eventService.createChallengeEvent(createChallengeEventDto)), HttpStatus.CREATED);
    }

    @GetMapping("/challenge/session/{sessionId}")
    public ResponseEntity<Page<EventResponseDto>> getChallengeEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getChallengeEventsBySession(sessionId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/challenge/child/{childId}/action/{action}")
    public ResponseEntity<Page<EventResponseDto>> getChallengeEventsByChildAndAction(
            @PathVariable int childId, @PathVariable EventAction action, Pageable pageable) {
        List<EventResponseDto> events = eventService.getChallengeEventsByChildAndAction(childId, action).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @PostMapping("/help")
    public ResponseEntity<EventResponseDto> createHelpEvent(@RequestBody CreateHelpEventDto createHelpEventDto) {
        return new ResponseEntity<>(EventResponseDto.from(eventService.createHelpEvent(createHelpEventDto)), HttpStatus.CREATED);
    }

    @GetMapping("/help/session/{sessionId}")
    public ResponseEntity<Page<EventResponseDto>> getHelpEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getHelpEventsBySession(sessionId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/help/child/{childId}/level/{helpLevel}")
    public ResponseEntity<Page<EventResponseDto>> getHelpEventsByChildAndLevel(
            @PathVariable int childId, @PathVariable HelpLevel helpLevel, Pageable pageable) {
        List<EventResponseDto> events = eventService.getHelpEventsByChildAndLevel(childId, helpLevel).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @PostMapping("/activity")
    public ResponseEntity<EventResponseDto> createActivityEvent(@RequestBody CreateActivityEventDto createActivityEventDto) {
        return new ResponseEntity<>(
                EventResponseDto.from(eventService.createActivityEvent(createActivityEventDto)),
                HttpStatus.CREATED);
    }

    @GetMapping("/activity/session/{sessionId}")
    public ResponseEntity<Page<EventResponseDto>> getActivityEventsBySession(@PathVariable int sessionId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getActivityEventsBySession(sessionId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<EventResponseDto>> getActivityEventsByActivity(@PathVariable int activityId, Pageable pageable) {
        List<EventResponseDto> events = eventService.getActivityEventsByActivity(activityId).stream()
                .map(EventResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(events, pageable), HttpStatus.OK);
    }
}
