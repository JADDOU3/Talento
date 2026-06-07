package org.example.backend.controller.mindset;

import org.example.backend.Dto.score.ChildMindsetScoreResponseDto;
import org.example.backend.Dto.score.CreateChildMindsetScoreDto;
import org.example.backend.Dto.score.UpdateChildMindsetScoreDto;
import org.example.backend.service.mindset.ChildMindsetScoreService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mindset-scores")
public class ChildMindsetScoreController {

    @Autowired
    private ChildMindsetScoreService childMindsetScoreService;

    @PostMapping
    public ResponseEntity<ChildMindsetScoreResponseDto> createScore(@RequestBody CreateChildMindsetScoreDto dto) {
        var score = childMindsetScoreService.createScore(dto);
        return score != null ? ResponseEntity.ok(ChildMindsetScoreResponseDto.from(score)) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<ChildMindsetScoreResponseDto>> getAll(Pageable pageable) {
        var dtos = childMindsetScoreService.getAll().stream().map(ChildMindsetScoreResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChildMindsetScoreResponseDto> getById(@PathVariable int id) {
        var score = childMindsetScoreService.getById(id);
        return score != null ? ResponseEntity.ok(ChildMindsetScoreResponseDto.from(score)) : ResponseEntity.notFound().build();
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<ChildMindsetScoreResponseDto>> getScoresByChild(@PathVariable int childId, Pageable pageable) {
        var dtos = childMindsetScoreService.getScoresByChild(childId).stream().map(ChildMindsetScoreResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<ChildMindsetScoreResponseDto>> getScoresByMindset(@PathVariable int mindsetId, Pageable pageable) {
        var dtos = childMindsetScoreService.getScoresByMindset(mindsetId).stream().map(ChildMindsetScoreResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ChildMindsetScoreResponseDto> updateScore(@PathVariable int id, @RequestBody UpdateChildMindsetScoreDto dto) {
        var score = childMindsetScoreService.updateScore(id, dto);
        return score != null ? ResponseEntity.ok(ChildMindsetScoreResponseDto.from(score)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteScore(@PathVariable int id) {
        childMindsetScoreService.deleteScore(id);
        return ResponseEntity.noContent().build();
    }
}
