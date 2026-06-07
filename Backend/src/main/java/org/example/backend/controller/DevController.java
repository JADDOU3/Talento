package org.example.backend.controller;

import org.example.backend.Dto.ai.response.AiAnalysisResponseDto;
import org.example.backend.model.Child;
import org.example.backend.repo.ChildRepo;
import org.example.backend.service.ai.AiAnalysisService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dev")
public class DevController {

    private final AiAnalysisService aiAnalysisService;
    private final ChildRepo childRepo;

    public DevController(AiAnalysisService aiAnalysisService, ChildRepo childRepo) {
        this.aiAnalysisService = aiAnalysisService;
        this.childRepo = childRepo;
    }

    @PostMapping("/ai/test")
    public ResponseEntity<?> testAiFlow(
            @RequestParam int childId,
            @RequestParam(defaultValue = "en") String responseLanguage
    ) {
        Child child = childRepo.findById(childId).orElse(null);
        if (child == null) {
            return ResponseEntity.badRequest().body("Child not found: " + childId);
        }

        try {
            AiAnalysisResponseDto result = aiAnalysisService.runAnalysis(child, responseLanguage);
            if (result == null) {
                return ResponseEntity.ok("No unanalyzed sessions found for this child.");
            }
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Analysis failed: " + e.getMessage());
        }
    }
}