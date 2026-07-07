package org.example.backend.repo.challenge;

import org.example.backend.model.DailyChallengeAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface DailyChallengeAttemptRepo extends JpaRepository<DailyChallengeAttempt, Integer> {
    Optional<DailyChallengeAttempt> findByChildIdAndAttemptDate(int childId, LocalDate date);
}