package org.example.backend.controller.challenge;

import org.example.backend.Dto.challenge.CreateChallengeCardDto;
import org.example.backend.Dto.challenge.UpdateChallengeCardDto;
import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.service.Challenge.ChallengeCardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/challenge-cards")
public class ChallengeCardController {

    @Autowired
    private ChallengeCardService challengeCardService;

    @PostMapping("/")
    public ResponseEntity<ChallengeCard> createChallengeCard(
            @RequestBody CreateChallengeCardDto createChallengeCardDto) {
        return new ResponseEntity<>(
                challengeCardService.createChallengeCard(createChallengeCardDto), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<List<ChallengeCard>> getAllChallengeCards() {
        return new ResponseEntity<>(challengeCardService.getAllChallengeCards(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChallengeCard> getChallengeCardById(@PathVariable int id) {
        ChallengeCard card = challengeCardService.getChallengeCardById(id);
        if (card == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(card, HttpStatus.OK);
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<List<ChallengeCard>> getChallengeCardsByActivity(
            @PathVariable int activityId) {
        return new ResponseEntity<>(
                challengeCardService.getChallengeCardsByActivity(activityId), HttpStatus.OK);
    }

    @PutMapping("/")
    public ResponseEntity<ChallengeCard> updateChallengeCard(
            @RequestBody UpdateChallengeCardDto updateChallengeCardDto) {
        if (challengeCardService.getChallengeCardById(updateChallengeCardDto.getId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                challengeCardService.updateChallengeCard(updateChallengeCardDto), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteChallengeCard(@PathVariable int id) {
        if (challengeCardService.getChallengeCardById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        challengeCardService.deleteChallengeCard(id);
        return new ResponseEntity<>("ChallengeCard deleted successfully", HttpStatus.OK);
    }
}


//todo implement the rest of the endpoints & test all (  events , help , challenge, level ) etc