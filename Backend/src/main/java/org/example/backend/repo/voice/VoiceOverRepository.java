package org.example.backend.repo.voice;

import org.example.backend.model.voice.VoiceOver;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VoiceOverRepository extends JpaRepository<VoiceOver, Integer> {

    Optional<VoiceOver> findByActivity_IdAndLevelIsNull(int activityId);

    Optional<VoiceOver> findByActivity_IdAndLevel_Id(int activityId, int levelId);
}