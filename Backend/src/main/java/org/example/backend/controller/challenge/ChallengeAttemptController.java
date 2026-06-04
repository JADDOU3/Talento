package org.example.backend.controller.challenge;

import org.example.backend.Dto.challenge.ChallengeAttemptResponseDto;
import org.example.backend.Dto.challenge.CreateChallengeAttemptDto;
import org.example.backend.service.Challenge.ChallengeAttemptService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/challenge-attempts")
public class ChallengeAttemptController {

    @Autowired
    private ChallengeAttemptService challengeAttemptService;

    @PostMapping("/")
    public ResponseEntity<ChallengeAttemptResponseDto> createChallengeAttempt(
            @RequestBody CreateChallengeAttemptDto createChallengeAttemptDto) {
        return new ResponseEntity<>(
                ChallengeAttemptResponseDto.from(challengeAttemptService.createChallengeAttempt(createChallengeAttemptDto)), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChallengeAttemptResponseDto> getChallengeAttemptById(@PathVariable int id) {
        var attempt = challengeAttemptService.getChallengeAttemptById(id);
        if (attempt == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(ChallengeAttemptResponseDto.from(attempt), HttpStatus.OK);
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<Page<ChallengeAttemptResponseDto>> getChallengeAttemptsByActivitySession(
            @PathVariable int activitySessionId, Pageable pageable) {
        var dtos = challengeAttemptService.getChallengeAttemptsByActivitySession(activitySessionId).stream()
                .map(ChallengeAttemptResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @GetMapping("/challenge-card/{challengeCardId}")
    public ResponseEntity<Page<ChallengeAttemptResponseDto>> getChallengeAttemptsByChallengeCard(
            @PathVariable int challengeCardId, Pageable pageable) {
        var dtos = challengeAttemptService.getChallengeAttemptsByChallengeCard(challengeCardId).stream()
                .map(ChallengeAttemptResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @PutMapping("/accept/{id}")
    public ResponseEntity<ChallengeAttemptResponseDto> acceptChallengeAttempt(
            @PathVariable int id, @RequestParam boolean accepted) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                ChallengeAttemptResponseDto.from(challengeAttemptService.markAccepted(id, accepted)), HttpStatus.OK);
    }

    @PutMapping("/complete/{id}")
    public ResponseEntity<ChallengeAttemptResponseDto> completeChallengeAttempt(
            @PathVariable int id, @RequestParam boolean completed) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                ChallengeAttemptResponseDto.from(challengeAttemptService.markCompleted(id, completed)), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteChallengeAttempt(@PathVariable int id) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        challengeAttemptService.deleteChallengeAttempt(id);
        return new ResponseEntity<>("ChallengeAttempt deleted successfully", HttpStatus.OK);
    }
}
