package org.example.backend.controller.level;

import org.example.backend.Dto.levelAttempt.CreateLevelAttemptDto;
import org.example.backend.model.level.LevelAttempt;
import org.example.backend.service.level.LevelAttemptService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/level-attempts")
public class LevelAttemptController {

    @Autowired
    private LevelAttemptService levelAttemptService;

    @PostMapping
    public ResponseEntity<LevelAttempt> createLevelAttempt(@RequestBody CreateLevelAttemptDto dto) {
        LevelAttempt attempt = levelAttemptService.createLevelAttempt(dto);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<List<LevelAttempt>> getAll() {
        return ResponseEntity.ok(levelAttemptService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<LevelAttempt> getById(@PathVariable int id) {
        LevelAttempt attempt = levelAttemptService.getLevelAttemptById(id);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<List<LevelAttempt>> getByActivitySession(@PathVariable int activitySessionId) {
        return ResponseEntity.ok(levelAttemptService.getAttemptsByActivitySession(activitySessionId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<LevelAttempt> updateLevelAttempt(@PathVariable int id, @RequestBody CreateLevelAttemptDto dto) {
        LevelAttempt attempt = levelAttemptService.updateLevelAttempt(id, dto);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLevelAttempt(@PathVariable int id) {
        levelAttemptService.deleteLevelAttempt(id);
        return ResponseEntity.noContent().build();
    }
}
