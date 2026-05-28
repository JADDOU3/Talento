package org.example.backend.controller.level;

import org.example.backend.Dto.level.CreateLevelDto;
import org.example.backend.Dto.level.LevelResponseDto;
import org.example.backend.Dto.level.UpdateLevelDto;
import org.example.backend.service.level.LevelService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/levels")
public class LevelController {

    @Autowired
    private LevelService levelService;

    @PostMapping
    public ResponseEntity<LevelResponseDto> createLevel(@RequestBody CreateLevelDto dto) {
        LevelResponseDto level = levelService.createLevel(dto);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<LevelResponseDto>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(levelService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<LevelResponseDto> getLevelById(@PathVariable int id) {
        LevelResponseDto level = levelService.getLevelById(id);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.notFound().build();
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<LevelResponseDto>> getLevelsByActivity(@PathVariable int activityId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(levelService.getLevelsByActivity(activityId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<LevelResponseDto> updateLevel(@PathVariable int id, @RequestBody UpdateLevelDto dto) {
        LevelResponseDto level = levelService.updateLevel(id, dto);
        return level != null ? ResponseEntity.ok(level) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLevel(@PathVariable int id) {
        levelService.deleteLevel(id);
        return ResponseEntity.noContent().build();
    }
}