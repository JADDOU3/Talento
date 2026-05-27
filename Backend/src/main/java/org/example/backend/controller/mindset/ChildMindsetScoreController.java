package org.example.backend.controller.mindset;

import org.example.backend.Dto.score.CreateChildMindsetScoreDto;
import org.example.backend.Dto.score.UpdateChildMindsetScoreDto;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.service.mindset.ChildMindsetScoreService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/child-mindset-scores")
public class ChildMindsetScoreController {

    @Autowired
    private ChildMindsetScoreService childMindsetScoreService;

    @PostMapping
    public ResponseEntity<ChildMindsetScore> createScore(@RequestBody CreateChildMindsetScoreDto dto) {
        ChildMindsetScore score = childMindsetScoreService.createScore(dto);
        return score != null ? ResponseEntity.ok(score) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<ChildMindsetScore>> getAll(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(childMindsetScoreService.getAll(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChildMindsetScore> getById(@PathVariable int id) {
        ChildMindsetScore score = childMindsetScoreService.getById(id);
        return score != null ? ResponseEntity.ok(score) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<ChildMindsetScore>> getScoresByChild(@PathVariable int childId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(childMindsetScoreService.getScoresByChild(childId), pageable));
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<ChildMindsetScore>> getScoresByMindset(@PathVariable int mindsetId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(childMindsetScoreService.getScoresByMindset(mindsetId), pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ChildMindsetScore> updateScore(@PathVariable int id, @RequestBody UpdateChildMindsetScoreDto dto) {
        ChildMindsetScore score = childMindsetScoreService.updateScore(id, dto);
        return score != null ? ResponseEntity.ok(score) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteScore(@PathVariable int id) {
        childMindsetScoreService.deleteScore(id);
        return ResponseEntity.noContent().build();
    }
}
