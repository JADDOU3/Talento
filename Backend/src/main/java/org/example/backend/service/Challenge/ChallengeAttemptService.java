package org.example.backend.service.Challenge;

import org.example.backend.Dto.challenge.CreateChallengeAttemptDto;
import org.example.backend.model.ActivitySession;
import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.example.backend.model.challengeCard.ChallengeCard;
import org.example.backend.repo.ActivitySessionRepo;
import org.example.backend.repo.challenge.ChallengeAttemptRepo;
import org.example.backend.repo.challenge.ChallengeCardRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChallengeAttemptService {

    @Autowired
    private ChallengeAttemptRepo challengeAttemptRepo;

    @Autowired
    private ActivitySessionRepo activitySessionRepo;

    @Autowired
    private ChallengeCardRepo challengeCardRepo;

    public ChallengeAttempt createChallengeAttempt(CreateChallengeAttemptDto createChallengeAttemptDto) {
        ActivitySession activitySession = activitySessionRepo.findById(createChallengeAttemptDto.getActivitySessionId())
                .orElseThrow(() -> new RuntimeException("ActivitySession not found"));
        ChallengeCard card = challengeCardRepo.findById(createChallengeAttemptDto.getChallengeCardId())
                .orElseThrow(() -> new RuntimeException("ChallengeCard not found"));

        ChallengeAttempt attempt = new ChallengeAttempt();
        attempt.setActivitySession(activitySession);
        attempt.setChallengeCard(card);
        attempt.setAccepted(false);
        attempt.setCompleted(false);
        attempt.setAttemptsCount(0);

        return challengeAttemptRepo.save(attempt);
    }

    public ChallengeAttempt getChallengeAttemptById(int id) {
        return challengeAttemptRepo.findById(id).orElse(null);
    }

    public List<ChallengeAttempt> getChallengeAttemptsByActivitySession(int activitySessionId) {
        return challengeAttemptRepo.findByActivitySessionId(activitySessionId);
    }

    public List<ChallengeAttempt> getChallengeAttemptsByChallengeCard(int challengeCardId) {
        return challengeAttemptRepo.findByChallengeCardId(challengeCardId);
    }

    public ChallengeAttempt markAccepted(int id, boolean accepted) {
        ChallengeAttempt attempt = challengeAttemptRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("ChallengeAttempt not found"));
        attempt.setAccepted(accepted);
        attempt.setAttemptsCount(attempt.getAttemptsCount() + 1);
        return challengeAttemptRepo.save(attempt);
    }

    public ChallengeAttempt markCompleted(int id, boolean completed) {
        ChallengeAttempt attempt = challengeAttemptRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("ChallengeAttempt not found"));
        attempt.setCompleted(completed);
        return challengeAttemptRepo.save(attempt);
    }

    public void deleteChallengeAttempt(int id) {
        challengeAttemptRepo.deleteById(id);
    }
}