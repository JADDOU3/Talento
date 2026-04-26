package org.example.backend.repo.event;

import org.example.backend.model.event.ActivityEvent;
import org.example.backend.util.enums.EventAction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ActivityEventRepo extends JpaRepository<ActivityEvent, Integer> {
    List<ActivityEvent> findByChildId(int childId);
    List<ActivityEvent> findBySessionId(int sessionId);
    List<ActivityEvent> findByAction(EventAction action);
    List<ActivityEvent> findByActivityId(int activityId);
    List<ActivityEvent> findByChildIdAndAction(int childId, EventAction action);
}