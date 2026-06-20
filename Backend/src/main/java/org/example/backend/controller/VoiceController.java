package org.example.backend.controller;

import org.example.backend.Dto.ai.request.VoiceKeywordCheckRequestDto;
import org.example.backend.Dto.ai.response.AiVoiceResponseDto;
import org.example.backend.Dto.ai.response.VoiceKeywordCheckResponseDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.ai.AiClientService;
import org.example.backend.util.ArabicTextUtil;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

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
        Activity activity = activityService.getRawActivityById(activityId);
        if (activity == null) {
            return ResponseEntity.notFound().build();
        }
        if (!Boolean.TRUE.equals(activity.getVoiceEnabled())) {
            return ResponseEntity.badRequest().build();
        }
        AiVoiceResponseDto response = aiClientService.transcribe(file);
        return ResponseEntity.ok(response);
    }

    @PostMapping(value = "/transcribe-with-keywords", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<VoiceKeywordCheckResponseDto> transcribeWithKeywords(
            @RequestPart("file") MultipartFile file,
            @RequestPart("request") VoiceKeywordCheckRequestDto request
    ) throws IOException {
        Activity activity = activityService.getRawActivityById(request.getActivityId());
        if (activity == null) {
            return ResponseEntity.notFound().build();
        }
        if (!Boolean.TRUE.equals(activity.getVoiceEnabled())) {
            return ResponseEntity.badRequest().build();
        }

        AiVoiceResponseDto transcription = aiClientService.transcribe(file);
        String text = transcription != null ? transcription.getText() : "";

        List<String> keywords = request.getKeywords() != null ? request.getKeywords() : Collections.emptyList();
        List<String> missingKeywords = ArabicTextUtil.findMissingKeywords(text, keywords);
        boolean success = missingKeywords.isEmpty();

        String message = success
                ? "Level completed successfully."
                : "The story didn't include the required keywords.";

        VoiceKeywordCheckResponseDto response = new VoiceKeywordCheckResponseDto(
                text,
                success,
                missingKeywords,
                message
        );
        return ResponseEntity.ok(response);
    }
}