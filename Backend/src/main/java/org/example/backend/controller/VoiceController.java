package org.example.backend.controller;

import org.example.backend.Dto.ai.response.AiVoiceResponseDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.ai.AiClientService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/voice")
public class VoiceController {

    private final ActivityService activityService;
    private final AiClientService aiClientService;

    public VoiceController(ActivityService activityService, AiClientService aiClientService) {
        this.activityService = activityService;
        this.aiClientService = aiClientService;
    }

    @PostMapping("/transcribe")
    public ResponseEntity<AiVoiceResponseDto> transcribe(
        @RequestParam("activityId") int activityId,
        @RequestParam("file") MultipartFile file
    ) throws IOException {
        Activity activity = activityService.getActivityById(activityId);
        if (activity == null) {
            return ResponseEntity.notFound().build();
        }
        if (!Boolean.TRUE.equals(activity.getVoiceEnabled())) {
            return ResponseEntity.badRequest().build();
        }
        AiVoiceResponseDto response = aiClientService.transcribe(file);
        return ResponseEntity.ok(response);
    }
}
