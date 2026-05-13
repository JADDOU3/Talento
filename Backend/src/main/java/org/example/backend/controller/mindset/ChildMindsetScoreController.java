package org.example.backend.controller.mindset;

import org.example.backend.Dto.score.CreateChildMindsetScoreDto;
import org.example.backend.Dto.score.UpdateChildMindsetScoreDto;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.service.mindset.ChildMindsetScoreService;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<List<ChildMindsetScore>> getAll() {
        return ResponseEntity.ok(childMindsetScoreService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChildMindsetScore> getById(@PathVariable int id) {
        ChildMindsetScore score = childMindsetScoreService.getById(id);
        return score != null ? ResponseEntity.ok(score) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<ChildMindsetScore>> getScoresByChild(@PathVariable int childId) {
        return ResponseEntity.ok(childMindsetScoreService.getScoresByChild(childId));
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<List<ChildMindsetScore>> getScoresByMindset(@PathVariable int mindsetId) {
        return ResponseEntity.ok(childMindsetScoreService.getScoresByMindset(mindsetId));
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
