package org.example.backend.controller.challenge;

import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeAnswerDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResponseDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResultDto;
import org.example.backend.service.Challenge.DailyChallengeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/daily-challenge")
public class DailyChallengeController {

    private final DailyChallengeService dailyChallengeService;

    public DailyChallengeController(DailyChallengeService dailyChallengeService) {
        this.dailyChallengeService = dailyChallengeService;
    }

    /**
     * GET /api/daily-challenge
     * Returns today's challenge question and 3 choices.
     * correctAnswer is NOT included in the response.
     */
    @GetMapping
    public ResponseEntity<DailyChallengeResponseDto> getDailyChallenge() {
        DailyChallengeResponseDto challenge = dailyChallengeService.getDailyChallenge();
        return challenge != null
                ? ResponseEntity.ok(challenge)
                : ResponseEntity.notFound().build();
    }

    /**
     * POST /api/daily-challenge/answer
     * Child submits their answer. Returns whether it's correct + the correct answer.
     */
    @PostMapping("/answer")
    public ResponseEntity<DailyChallengeResultDto> checkAnswer(
            @RequestBody DailyChallengeAnswerDto dto) {
        DailyChallengeResultDto result = dailyChallengeService.checkAnswer(dto);
        return result != null
                ? ResponseEntity.ok(result)
                : ResponseEntity.notFound().build();
    }
}