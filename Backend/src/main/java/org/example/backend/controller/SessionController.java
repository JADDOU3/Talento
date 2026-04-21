package org.example.backend.controller;

import org.example.backend.Dto.SessionStartDto;
import org.example.backend.model.Session;
import org.example.backend.service.ChildService;
import org.example.backend.service.KitService;
import org.example.backend.service.SessionService;
import org.springframework.beans.factory.annotation.Autowired;
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
        return new ResponseEntity<>(sessionService.startSession(sessionStartDto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Session> getSessionById(@PathVariable int id) {
        Session session = sessionService.getSessionById(id);
        if(session == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(session, HttpStatus.OK);
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<Session>> getAllSessionsByChild(@PathVariable int childId) {
        if(childService.getChildById(childId) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(sessionService.getAllSessionsByChild(childId), HttpStatus.OK);
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<List<Session>> getAllSessionsByKit(@PathVariable int kitId) {
        if(kitService.getKitById(kitId) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(sessionService.getAllSessionsByKit(kitId), HttpStatus.OK);
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