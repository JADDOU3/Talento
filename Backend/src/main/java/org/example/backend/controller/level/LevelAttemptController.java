package org.example.backend.controller.level;

import org.example.backend.Dto.levelAttempt.CreateLevelAttemptDto;
import org.example.backend.Dto.levelAttempt.LevelAttemptResponseDto;
import org.example.backend.service.level.LevelAttemptService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/level-attempts")
public class LevelAttemptController {

    @Autowired
    private LevelAttemptService levelAttemptService;

    @PostMapping
    public ResponseEntity<LevelAttemptResponseDto> createLevelAttempt(@RequestBody CreateLevelAttemptDto dto) {
        LevelAttemptResponseDto attempt = levelAttemptService.createLevelAttempt(dto);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<LevelAttemptResponseDto>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(levelAttemptService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<LevelAttemptResponseDto> getById(@PathVariable int id) {
        LevelAttemptResponseDto attempt = levelAttemptService.getLevelAttemptById(id);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<Page<LevelAttemptResponseDto>> getByActivitySession(@PathVariable int activitySessionId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(levelAttemptService.getAttemptsByActivitySession(activitySessionId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<LevelAttemptResponseDto> updateLevelAttempt(@PathVariable int id, @RequestBody CreateLevelAttemptDto dto) {
        LevelAttemptResponseDto attempt = levelAttemptService.updateLevelAttempt(id, dto);
        return attempt != null ? ResponseEntity.ok(attempt) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLevelAttempt(@PathVariable int id) {
        levelAttemptService.deleteLevelAttempt(id);
        return ResponseEntity.noContent().build();
    }
}
