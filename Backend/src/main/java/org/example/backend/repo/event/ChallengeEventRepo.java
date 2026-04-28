package org.example.backend.repo.event;

import org.example.backend.model.event.ChallengeEvent;
import org.example.backend.util.enums.EventAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChallengeEventRepo extends JpaRepository<ChallengeEvent, Integer> {
    List<ChallengeEvent> findByChildId(int childId);
    List<ChallengeEvent> findBySessionId(int sessionId);
    List<ChallengeEvent> findByAction(EventAction action);
    List<ChallengeEvent> findByChildIdAndAction(int childId, EventAction action);
}