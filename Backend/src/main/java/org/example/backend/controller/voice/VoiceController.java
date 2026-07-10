package org.example.backend.controller.voice;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.example.backend.Dto.ai.request.VoiceKeywordCheckRequestDto;
import org.example.backend.Dto.ai.response.AiVoiceResponseDto;
import org.example.backend.Dto.ai.response.VoiceKeywordCheckResponseDto;
import org.example.backend.Dto.level.LevelStorySubmissionResponseDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.ai.AiClientService;
import org.example.backend.service.level.LevelStorySubmissionService;
import org.example.backend.util.ArabicTextUtil;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/voice")
@RequiredArgsConstructor
public class VoiceController {

    private final ActivityService activityService;
    private final AiClientService aiClientService;
    private final LevelStorySubmissionService levelStorySubmissionService;

    // ── Endpoints ─────────────────────────────────────────────────────────────

    /**
     * POST /api/voice/transcribe
     *
     * Simple transcription — no keyword check, no saving.
     * Used for activities that only need raw voice-to-text.
     */
    @PostMapping("/transcribe")
    public ResponseEntity<AiVoiceResponseDto> transcribe(
            @RequestParam("activityId") int activityId,
            @RequestParam("file") MultipartFile file
    ) throws IOException {
        Activity activity = activityService.getRawActivityById(activityId);
        if (activity == null) return ResponseEntity.notFound().build();
        if (!Boolean.TRUE.equals(activity.getVoiceEnabled())) return ResponseEntity.badRequest().build();

        return ResponseEntity.ok(aiClientService.transcribe(file));
    }

    /**
     * POST /api/voice/transcribe-with-keywords  (multipart/form-data)
     *
     * Transcribes the audio, checks for required keywords, and — on success —
     * optionally persists the story if activitySessionId and levelId are provided.
     *
     * Request parts:
     *   - file    : the audio recording
     *   - request : JSON matching VoiceKeywordCheckRequestDto
     *
     * Response fields:
     *   - text              : full transcribed text
     *   - success           : true if all keywords were found
     *   - missingKeywords   : keywords that were not detected (empty on success)
     *   - message           : human-readable result
     *   - savedSubmissionId : ID of the saved story, or null if not saved
     */
    @PostMapping(value = "/transcribe-with-keywords", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<VoiceKeywordCheckResponseDto> transcribeWithKeywords(
            @RequestPart("file") MultipartFile file,
            @Valid @RequestPart("request") VoiceKeywordCheckRequestDto request
    ) throws IOException {

        // 1. Validate activity exists and has voice enabled.
        Activity activity = activityService.getRawActivityById(request.getActivityId());
        if (activity == null) return ResponseEntity.notFound().build();
        if (!Boolean.TRUE.equals(activity.getVoiceEnabled())) return ResponseEntity.badRequest().build();

        // 2. Transcribe the audio.
        AiVoiceResponseDto transcription = aiClientService.transcribe(file);
        String text = (transcription != null && transcription.getText() != null)
                ? transcription.getText()
                : "";

        // 3. Check keywords.
        List<String> keywords = request.getKeywords() != null
                ? request.getKeywords()
                : Collections.emptyList();

        List<String> missingKeywords = ArabicTextUtil.findMissingKeywords(text, keywords);
        boolean success = missingKeywords.isEmpty();

        // 4. Save on success only.
        Integer savedSubmissionId = null;
        if (success) {
            LevelStorySubmissionResponseDto saved = levelStorySubmissionService.saveSuccessfulSubmission(
                    request.getActivitySessionId(),
                    request.getLevelId(),
                    text,
                    keywords
            );
            if (saved != null) {
                savedSubmissionId = saved.getId();
            }
        }

        // 5. Build and return the response.
        String message = success
                ? "Level completed successfully."
                : "The story didn't include the required keywords.";

        return ResponseEntity.ok(VoiceKeywordCheckResponseDto.builder()
                .text(text)
                .success(success)
                .missingKeywords(missingKeywords)
                .message(message)
                .savedSubmissionId(savedSubmissionId)
                .build());
    }
}