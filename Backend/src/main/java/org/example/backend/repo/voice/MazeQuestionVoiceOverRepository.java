package org.example.backend.repo.voice;

import org.example.backend.model.voice.MazeQuestionVoiceOver;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MazeQuestionVoiceOverRepository extends JpaRepository<MazeQuestionVoiceOver, Integer> {
    Optional<MazeQuestionVoiceOver> findByLevel_IdAndChallengeId(int levelId, int challengeId);
}