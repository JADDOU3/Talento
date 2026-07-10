package org.example.backend.repo.voice;

import org.example.backend.model.voice.GlobalVoiceOver;
import org.example.backend.util.enums.VoiceType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface GlobalVoiceOverRepository extends JpaRepository<GlobalVoiceOver, Integer> {
    Optional<GlobalVoiceOver> findByType(VoiceType type);
}