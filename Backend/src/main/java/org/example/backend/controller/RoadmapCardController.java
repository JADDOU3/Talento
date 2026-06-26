package org.example.backend.controller;

import org.example.backend.Dto.roadmap.CreateRoadmapCardDto;
import org.example.backend.Dto.roadmap.RoadmapCardDto;
import org.example.backend.service.roadmap.RoadmapService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/roadmap-cards")
public class RoadmapCardController {

    private final RoadmapService roadmapService;

    public RoadmapCardController(RoadmapService roadmapService) {
        this.roadmapService = roadmapService;
    }

    @PostMapping
    public ResponseEntity<RoadmapCardDto> create(
            @RequestBody CreateRoadmapCardDto dto) {
        RoadmapCardDto result = roadmapService.create(dto);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.badRequest().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<RoadmapCardDto> update(
            @PathVariable int id,
            @RequestBody CreateRoadmapCardDto dto) {
        RoadmapCardDto result = roadmapService.update(id, dto);
        return result != null ? ResponseEntity.ok(result) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        roadmapService.delete(id);
        return ResponseEntity.noContent().build();
    }
}