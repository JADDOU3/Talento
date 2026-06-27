package org.example.backend.repo.challenge;

import org.example.backend.model.DailyChallenge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DailyChallengeRepo extends JpaRepository<DailyChallenge, Integer> {
    List<DailyChallenge> findAllByOrderByIdAsc();
}