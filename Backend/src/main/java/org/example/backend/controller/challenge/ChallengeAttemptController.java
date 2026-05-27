package org.example.backend.controller.challenge;

import org.example.backend.Dto.challenge.CreateChallengeAttemptDto;
import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.example.backend.service.Challenge.ChallengeAttemptService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/challenge-attempts")
public class ChallengeAttemptController {

    @Autowired
    private ChallengeAttemptService challengeAttemptService;

    @PostMapping("/")
    public ResponseEntity<ChallengeAttempt> createChallengeAttempt(
            @RequestBody CreateChallengeAttemptDto createChallengeAttemptDto) {
        return new ResponseEntity<>(
                challengeAttemptService.createChallengeAttempt(createChallengeAttemptDto), HttpStatus.CREATED);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChallengeAttempt> getChallengeAttemptById(@PathVariable int id) {
        ChallengeAttempt attempt = challengeAttemptService.getChallengeAttemptById(id);
        if (attempt == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(attempt, HttpStatus.OK);
    }

    @GetMapping("/activity-session/{activitySessionId}")
    public ResponseEntity<Page<ChallengeAttempt>> getChallengeAttemptsByActivitySession(
            @PathVariable int activitySessionId, Pageable pageable) {
        return new ResponseEntity<>(
                PaginationUtil.paginate(challengeAttemptService.getChallengeAttemptsByActivitySession(activitySessionId), pageable),
                HttpStatus.OK);
    }

    @GetMapping("/challenge-card/{challengeCardId}")
    public ResponseEntity<Page<ChallengeAttempt>> getChallengeAttemptsByChallengeCard(
            @PathVariable int challengeCardId, Pageable pageable) {
        return new ResponseEntity<>(
                PaginationUtil.paginate(challengeAttemptService.getChallengeAttemptsByChallengeCard(challengeCardId), pageable),
                HttpStatus.OK);
    }

    @PutMapping("/accept/{id}")
    public ResponseEntity<ChallengeAttempt> acceptChallengeAttempt(
            @PathVariable int id, @RequestParam boolean accepted) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                challengeAttemptService.markAccepted(id, accepted), HttpStatus.OK);
    }

    @PutMapping("/complete/{id}")
    public ResponseEntity<ChallengeAttempt> completeChallengeAttempt(
            @PathVariable int id, @RequestParam boolean completed) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                challengeAttemptService.markCompleted(id, completed), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteChallengeAttempt(@PathVariable int id) {
        if (challengeAttemptService.getChallengeAttemptById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        challengeAttemptService.deleteChallengeAttempt(id);
        return new ResponseEntity<>("ChallengeAttempt deleted successfully", HttpStatus.OK);
    }
}