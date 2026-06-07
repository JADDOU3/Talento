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
     * Finds all ActivitySessions for a child where the session ended after the cutoff.
     * Used to collect everything not included in the last AIReport.
     * Sessions with null endedAt are included — they started but weren't cleanly closed.
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

    /**
     * Finds ALL ActivitySessions for a child — used when there is no previous report.
     */
    @Query("""
        SELECT a FROM ActivitySession a
        WHERE a.session.child.id = :childId
        ORDER BY a.startedAt ASC
    """)
    List<ActivitySession> findAllByChildId(@Param("childId") int childId);
}
