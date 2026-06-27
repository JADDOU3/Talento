package org.example.backend.repo;

import org.example.backend.model.DailyChallenge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DailyChallengeRepo extends JpaRepository<DailyChallenge, Integer> {
}