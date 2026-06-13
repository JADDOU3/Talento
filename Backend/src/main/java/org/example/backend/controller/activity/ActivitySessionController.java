package org.example.backend.controller.activity;

import org.example.backend.Dto.activitySession.ActivitySessionResponseDto;
import org.example.backend.Dto.activitySession.StartActivitySessionDto;
import org.example.backend.Dto.activitySession.UpdateActivitySessionDto;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.activity.ActivitySessionService;
import org.example.backend.service.SessionService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/activity-sessions")
public class ActivitySessionController {

    @Autowired
    private ActivitySessionService activitySessionService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private SessionService sessionService;

    @PostMapping("/")
    public ResponseEntity<ActivitySessionResponseDto> createActivitySession(@RequestBody StartActivitySessionDto startActivitySessionDtoto) {
        if (activityService.getActivityById(startActivitySessionDtoto.getActivityId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        if (sessionService.getSessionById(startActivitySessionDtoto.getSessionId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        return new ResponseEntity<>(activitySessionService.createActivitySession(startActivitySessionDtoto), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<Page<ActivitySessionResponseDto>> getAllActivitySessions(Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(activitySessionService.getAllActivitySessions(), pageable), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ActivitySessionResponseDto> getActivitySessionById(@PathVariable int id) {
        ActivitySessionResponseDto activitySession = activitySessionService.getActivitySessionById(id);
        if (activitySession == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(activitySession, HttpStatus.OK);
    }

    @GetMapping("/session/{sessionId}")
    public ResponseEntity<Page<ActivitySessionResponseDto>> getAllActivitySessionsBySession(@PathVariable int sessionId, Pageable pageable) {
        if (sessionService.getSessionById(sessionId) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(activitySessionService.getAllActivitySessionsBySession(sessionId), pageable), HttpStatus.OK);
    }

    @PutMapping("/")
    public ResponseEntity<ActivitySessionResponseDto> updateActivitySession(@RequestBody UpdateActivitySessionDto updateActivitySessionDto) {
        if (activitySessionService.getActivitySessionById(updateActivitySessionDto.getId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        if (activityService.getActivityById(updateActivitySessionDto.getActivityId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        if (sessionService.getSessionById(updateActivitySessionDto.getSessionId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(activitySessionService.updateActivitySession(updateActivitySessionDto), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteActivitySession(@PathVariable int id) {
        if (activitySessionService.getActivitySessionById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        activitySessionService.deleteActivitySession(id);
        return new ResponseEntity<>("ActivitySession deleted successfully", HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ActivitySessionResponseDto> endActivitySession(@PathVariable int id) {
        if (activitySessionService.getActivitySessionById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(activitySessionService.endActivitySession(id), HttpStatus.OK);
    }
}
