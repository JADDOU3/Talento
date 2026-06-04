package org.example.backend.controller;

import org.example.backend.Dto.roadmap.RoadmapResponseDto;
import org.example.backend.service.roadmap.RoadmapService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/roadmap")
public class RoadmapController {

    @Autowired
    private RoadmapService roadmapService;

    @GetMapping("/kit/{kitId}/child/{childId}")
    public ResponseEntity<RoadmapResponseDto> getRoadmap(
        @PathVariable int kitId,
        @PathVariable int childId
    ) {
        RoadmapResponseDto response = roadmapService.getRoadmap(kitId, childId);
        if (response == null) {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}

