package org.example.backend.controller;

import org.example.backend.Dto.level.CreateLevelDto;
import org.example.backend.Dto.level.UpdateLevelDto;
import org.example.backend.model.level.Level;
import org.example.backend.service.LevelService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/levels")
public class LevelController {

    @Autowired
    private LevelService levelService;

    @PostMapping
    public ResponseEntity<Level> createLevel(@RequestBody CreateLevelDto dto) {
        Level level = levelService.createLevel(dto);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<List<Level>> getAll() {
        return ResponseEntity.ok(levelService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Level> getLevelById(@PathVariable int id) {
        Level level = levelService.getLevelById(id);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<List<Level>> getLevelsByActivity(@PathVariable int activityId) {
        return ResponseEntity.ok(levelService.getLevelsByActivity(activityId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Level> updateLevel(@PathVariable int id, @RequestBody UpdateLevelDto dto) {
        Level level = levelService.updateLevel(id, dto);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLevel(@PathVariable int id) {
        levelService.deleteLevel(id);
        return ResponseEntity.noContent().build();
    }
}
