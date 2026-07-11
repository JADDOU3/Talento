package org.example.backend.controller.voice;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.voice.ActivityVoiceResponse;
import org.example.backend.Dto.voice.VoiceUrlResponse;
import org.example.backend.service.voice.VoiceService;
import org.example.backend.util.enums.VoiceType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/voice-over")
@RequiredArgsConstructor
public class VoiceOverController {

    private final VoiceService voiceService;

    // ---- GET endpoints ----

    @GetMapping("/global/{type}")
    public ResponseEntity<VoiceUrlResponse> getGlobalVoice(@PathVariable VoiceType type) {
        return ResponseEntity.ok(voiceService.getGlobalVoice(type));
    }

    @GetMapping("/activity/{id}")
    public ResponseEntity<ActivityVoiceResponse> getActivityVoice(
            @PathVariable int id,
            @RequestParam(required = false) Integer level) {
        return ResponseEntity.ok(voiceService.getActivityVoice(id, level));
    }

    @GetMapping("/maze-question/{levelId}/{challengeId}")
    public ResponseEntity<VoiceUrlResponse> getMazeQuestionVoice(
            @PathVariable int levelId,
            @PathVariable int challengeId) {
        return ResponseEntity.ok(voiceService.getMazeQuestionVoice(levelId, challengeId));
    }

    // ---- Upload endpoints ----

    @PostMapping("/upload/global/{type}")
    public ResponseEntity<Map<String, String>> uploadGlobalVoice(
            @PathVariable VoiceType type,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File must not be empty"));
        }
        String key = voiceService.uploadGlobalVoice(type, file);
        return ResponseEntity.ok(Map.of("s3Key", key));
    }

    @PostMapping("/upload/activity/{id}")
    public ResponseEntity<Map<String, String>> uploadActivityVoice(
            @PathVariable int id,
            @RequestParam(required = false) Integer level,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File must not be empty"));
        }
        String key = voiceService.uploadActivityVoice(id, level, file);
        return ResponseEntity.ok(Map.of("s3Key", key));
    }

    @PostMapping("/upload/maze-question/{levelId}/{challengeId}")
    public ResponseEntity<Map<String, String>> uploadMazeQuestionVoice(
            @PathVariable int levelId,
            @PathVariable int challengeId,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "File must not be empty"));
        }
        String key = voiceService.uploadMazeQuestionVoice(levelId, challengeId, file);
        return ResponseEntity.ok(Map.of("s3Key", key));
    }
}