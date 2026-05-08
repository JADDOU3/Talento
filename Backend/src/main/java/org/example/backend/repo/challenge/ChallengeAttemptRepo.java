package org.example.backend.repo.challenge;

import org.example.backend.model.challengeCard.ChallengeAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChallengeAttemptRepo extends JpaRepository<ChallengeAttempt, Integer> {
    List<ChallengeAttempt> findByActivitySessionId(int activitySessionId);
    List<ChallengeAttempt> findByChallengeCardId(int challengeCardId);
}