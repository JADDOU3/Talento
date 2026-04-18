package org.example.backend.controller;

import org.example.backend.Dto.SessionDto;
import org.example.backend.model.Session;
import org.example.backend.service.SessionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/sessions")
public class SessionController {

    @Autowired
    private SessionService sessionService;

    @PostMapping("")
    public Session createSession(@RequestBody SessionDto dto) {
        return sessionService.createSession(dto);
    }

    @GetMapping("/{id}")
    public Session getSessionById(@PathVariable int id) {
        return sessionService.getSessionById(id);
    }

    @GetMapping("/child/{childId}")
    public List<Session> getAllSessionsByChild(@PathVariable int childId) {
        return sessionService.getAllSessionsByChild(childId);
    }

    @PutMapping("/{id}")
    public Session updateSession(@PathVariable int id, @RequestBody SessionDto dto) {
        return sessionService.updateSession(id, dto);
    }

    @DeleteMapping("/{id}")
    public void deleteSession(@PathVariable int id) {
        sessionService.deleteSession(id);
    }

    @PatchMapping("/{id}/end")
    public Session endSession(@PathVariable int id) {
        return sessionService.endSession(id);
    }
}