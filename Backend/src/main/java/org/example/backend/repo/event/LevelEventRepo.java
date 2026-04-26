package org.example.backend.repo.event;

import org.example.backend.model.event.LevelEvent;
import org.example.backend.util.enums.EventAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LevelEventRepo extends JpaRepository<LevelEvent, Integer> {
    List<LevelEvent> findByChildId(int childId);
    List<LevelEvent> findBySessionId(int sessionId);
    List<LevelEvent> findByAction(EventAction action);
    List<LevelEvent> findByChildIdAndAction(int childId, EventAction action);
}