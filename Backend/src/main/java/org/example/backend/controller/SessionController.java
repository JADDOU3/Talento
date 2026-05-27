package org.example.backend.controller;

import org.example.backend.Dto.SessionStartDto;
import org.example.backend.model.Session;
import org.example.backend.service.ChildService;
import org.example.backend.service.KitService;
import org.example.backend.service.SessionService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sessions")
public class SessionController {

    @Autowired
    private SessionService sessionService;
    @Autowired
    private KitService kitService;
    @Autowired
    private ChildService childService;

    @PostMapping("/")
    public ResponseEntity<Session> startSession(@RequestBody SessionStartDto sessionStartDto) {
        if(kitService.getKitById(sessionStartDto.getKitId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        if(childService.getChildById(sessionStartDto.getChildId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        Session session = sessionService.startSession(sessionStartDto);
        if(session == null)
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        return new ResponseEntity<>(session, HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Session> getSessionById(@PathVariable int id) {
        Session session = sessionService.getSessionById(id);
        if(session == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(session, HttpStatus.OK);
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<Session>> getAllSessionsByChild(@PathVariable int childId, Pageable pageable) {
        if(childService.getChildById(childId) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(sessionService.getAllSessionsByChild(childId), pageable), HttpStatus.OK);
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<Page<Session>> getAllSessionsByKit(@PathVariable int kitId, Pageable pageable) {
        if(kitService.getKitById(kitId) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(sessionService.getAllSessionsByKit(kitId), pageable), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public void deleteSession(@PathVariable int id) {
        sessionService.deleteSession(id);
    }

    @PatchMapping("/{id}/end")
    public ResponseEntity<Session> endSession(@PathVariable int id) {
        if(sessionService.getSessionById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(sessionService.endSession(id), HttpStatus.OK);
    }
}