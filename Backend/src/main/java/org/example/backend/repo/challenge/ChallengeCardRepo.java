package org.example.backend.repo.challenge;

import org.example.backend.model.challengeCard.ChallengeCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChallengeCardRepo extends JpaRepository<ChallengeCard, Integer> {
    List<ChallengeCard> findByActivityId(int activityId);
}