package org.example.backend.repo.activity;

import org.example.backend.model.activity.ActivitySession;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ActivitySessionRepo extends JpaRepository<ActivitySession, Integer> {

    List<ActivitySession> findBySessionId(int sessionId);

    /**
     * All ActivitySessions for a child+activity across ALL sessions (not just the latest).
     * Used by RoadmapService to check if the activity was EVER completed.
     */
    @Query("""
        SELECT a FROM ActivitySession a
        WHERE a.session.child.id = :childId
          AND a.activity.id = :activityId
        ORDER BY a.startedAt ASC
    """)
    List<ActivitySession> findAllByChildIdAndActivityId(
            @Param("childId") int childId,
            @Param("activityId") int activityId
    );

    /**
     * All ActivitySessions for a child across ALL sessions.
     * Used by RoadmapService to build the full roadmap.
     */
    @Query("""
        SELECT a FROM ActivitySession a
        WHERE a.session.child.id = :childId
        ORDER BY a.startedAt ASC
    """)
    List<ActivitySession> findAllByChildId(@Param("childId") int childId);

    /**
     * Finds all ActivitySessions for a child where the session ended after the cutoff.
     * Used to collect everything not included in the last AIReport.
     */
    @Query("""
        SELECT a FROM ActivitySession a
        WHERE a.session.child.id = :childId
          AND (a.endedAt IS NULL OR a.endedAt > :cutoff)
        ORDER BY a.startedAt ASC
    """)
    List<ActivitySession> findByChildIdAfterCutoff(
            @Param("childId") int childId,
            @Param("cutoff") LocalDateTime cutoff
    );

    @Query(value = """
    SELECT DATE(a.started_at) as date, COUNT(*) as count
    FROM activity_session a
    INNER JOIN session s ON a.session_id = s.id
    WHERE s.child_id = :childId
      AND a.started_at >= :from
    GROUP BY DATE(a.started_at)
    ORDER BY DATE(a.started_at) ASC
""", nativeQuery = true)
    List<Object[]> countSessionsPerDayByChildId(
            @Param("childId") int childId,
            @Param("from") LocalDateTime from
    );
}