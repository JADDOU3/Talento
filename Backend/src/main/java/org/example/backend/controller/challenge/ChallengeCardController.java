package org.example.backend.controller.challenge;

import org.example.backend.Dto.challenge.ChallengeCardResponseDto;
import org.example.backend.Dto.challenge.CreateChallengeCardDto;
import org.example.backend.Dto.challenge.UpdateChallengeCardDto;
import org.example.backend.service.Challenge.ChallengeCardService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/challenge-cards")
public class ChallengeCardController {

    @Autowired
    private ChallengeCardService challengeCardService;

    @PostMapping("/")
    public ResponseEntity<ChallengeCardResponseDto> createChallengeCard(
            @RequestBody CreateChallengeCardDto createChallengeCardDto) {
        return new ResponseEntity<>(
                ChallengeCardResponseDto.from(challengeCardService.createChallengeCard(createChallengeCardDto)), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<Page<ChallengeCardResponseDto>> getAllChallengeCards(Pageable pageable) {
        var dtos = challengeCardService.getAllChallengeCards().stream().map(ChallengeCardResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChallengeCardResponseDto> getChallengeCardById(@PathVariable int id) {
        var card = challengeCardService.getChallengeCardById(id);
        if (card == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(ChallengeCardResponseDto.from(card), HttpStatus.OK);
    }

    @GetMapping("/activity/{activityId}")
    public ResponseEntity<Page<ChallengeCardResponseDto>> getChallengeCardsByActivity(
            @PathVariable int activityId, Pageable pageable) {
        var dtos = challengeCardService.getChallengeCardsByActivity(activityId).stream().map(ChallengeCardResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @PutMapping("/")
    public ResponseEntity<ChallengeCardResponseDto> updateChallengeCard(
            @RequestBody UpdateChallengeCardDto updateChallengeCardDto) {
        if (challengeCardService.getChallengeCardById(updateChallengeCardDto.getId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(
                ChallengeCardResponseDto.from(challengeCardService.updateChallengeCard(updateChallengeCardDto)), HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteChallengeCard(@PathVariable int id) {
        if (challengeCardService.getChallengeCardById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        challengeCardService.deleteChallengeCard(id);
        return new ResponseEntity<>("ChallengeCard deleted successfully", HttpStatus.OK);
    }
}
