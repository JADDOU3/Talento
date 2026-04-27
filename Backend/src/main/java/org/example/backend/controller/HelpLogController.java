package org.example.backend.controller;

import org.example.backend.Dto.CreateHelpLogDto;
import org.example.backend.model.HelpLog;
import org.example.backend.service.HelpLogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/help-logs")
public class HelpLogController {

    @Autowired
    private HelpLogService helpLogService;

    @PostMapping("/")
    public ResponseEntity<HelpLog> createHelpLog(@RequestBody CreateHelpLogDto createHelpLogDto) {
        return new ResponseEntity<>(helpLogService.createHelpLog(createHelpLogDto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<HelpLog> getHelpLogById(@PathVariable int id) {
        HelpLog helpLog = helpLogService.getHelpLogById(id);
        if (helpLog == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(helpLog, HttpStatus.OK);
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<List<HelpLog>> getHelpLogsByActivitySession(
            @PathVariable int activitySessionId) {
        return new ResponseEntity<>(
                helpLogService.getHelpLogsByActivitySession(activitySessionId), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteHelpLog(@PathVariable int id) {
        if (helpLogService.getHelpLogById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        helpLogService.deleteHelpLog(id);
        return new ResponseEntity<>("HelpLog deleted successfully", HttpStatus.OK);
    }
}