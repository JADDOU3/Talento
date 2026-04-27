package org.example.backend.service.Challenge;

import org.example.backend.Dto.challenge.CreateChallengeCardDto;
import org.example.backend.Dto.challenge.UpdateChallengeCardDto;
import org.example.backend.model.Activity;
import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.repo.ActivityRepo;
import org.example.backend.repo.challenge.ChallengeCardRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChallengeCardService {

    @Autowired
    private ChallengeCardRepo challengeCardRepo;

    @Autowired
    private ActivityRepo activityRepo;

    public ChallengeCard createChallengeCard(CreateChallengeCardDto createChallengeCardDto) {
        Activity activity = activityRepo.findById(createChallengeCardDto.getActivityId())
                .orElseThrow(() -> new RuntimeException("Activity not found"));

        ChallengeCard card = new ChallengeCard();
        card.setType(createChallengeCardDto.getType());
        card.setTitle(createChallengeCardDto.getTitle());
        card.setDescription(createChallengeCardDto.getDescription());
        card.setActivity(activity);

        return challengeCardRepo.save(card);
    }

    public List<ChallengeCard> getAllChallengeCards() {
        return challengeCardRepo.findAll();
    }

    public ChallengeCard getChallengeCardById(int id) {
        return challengeCardRepo.findById(id).orElse(null);
    }

    public List<ChallengeCard> getChallengeCardsByActivity(int activityId) {
        return challengeCardRepo.findByActivityId(activityId);
    }

    public ChallengeCard updateChallengeCard(UpdateChallengeCardDto updateChallengeCardDto) {
        ChallengeCard card = challengeCardRepo.findById(updateChallengeCardDto.getId())
                .orElseThrow(() -> new RuntimeException("ChallengeCard not found"));
        Activity activity = activityRepo.findById(updateChallengeCardDto.getActivityId())
                .orElseThrow(() -> new RuntimeException("Activity not found"));

        card.setType(updateChallengeCardDto.getType());
        card.setTitle(updateChallengeCardDto.getTitle());
        card.setDescription(updateChallengeCardDto.getDescription());
        card.setActivity(activity);

        return challengeCardRepo.save(card);
    }

    public void deleteChallengeCard(int id) {
        challengeCardRepo.deleteById(id);
    }
}