package org.example.backend.repo.event;

import org.example.backend.model.event.Event;
import org.example.backend.util.enums.EventType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventRepo extends JpaRepository<Event, Integer> {
    List<Event> findByChildId(int childId);
    List<Event> findBySessionId(int sessionId);
    List<Event> findByActivityId(int activityId);
    List<Event> findByActivitySessionId(int activitySessionId);
    List<Event> findByChildIdAndType(int childId, EventType type);
    List<Event> findBySessionIdAndType(int sessionId, EventType type);
}