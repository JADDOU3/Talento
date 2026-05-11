package org.example.backend.repo.event;

import org.example.backend.model.event.Event;
import org.example.backend.util.enums.EventType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EventRepo extends JpaRepository<Event, Integer> {
    List<Event> findByChildId(int childId);
    List<Event> findBySessionId(int sessionId);
    List<Event> findByActivityId(int activityId);
    @Query("SELECT e FROM Event e WHERE e.child.id = :childId AND " +
           "( (:type = org.example.backend.util.enums.EventType.LEVEL AND TYPE(e) = LevelEvent) OR " +
           "  (:type = org.example.backend.util.enums.EventType.CHALLENGE AND TYPE(e) = ChallengeEvent) OR " +
           "  (:type = org.example.backend.util.enums.EventType.HELP AND TYPE(e) = HelpEvent) OR " +
           "  (:type = org.example.backend.util.enums.EventType.ACTIVITY AND TYPE(e) = ActivityEvent) )")
    List<Event> findByChildIdAndType(@Param("childId") int childId, @Param("type") EventType type);
}