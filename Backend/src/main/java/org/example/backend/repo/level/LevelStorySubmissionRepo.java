package org.example.backend.repo.level;

import org.example.backend.model.level.LevelStorySubmission;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LevelStorySubmissionRepo extends JpaRepository<LevelStorySubmission, Integer> {


    List<LevelStorySubmission> findByActivitySession_IdOrderBySubmittedAtDesc(int activitySessionId);

    boolean existsByActivitySession_IdAndLevel_Id(int activitySessionId, int levelId);

    @Query("""
        SELECT s FROM LevelStorySubmission s
        WHERE s.activitySession.activity.id = :activityId
        ORDER BY s.submittedAt DESC
    """)
    List<LevelStorySubmission> findByActivityId(@Param("activityId") int activityId);

    @Query("SELECT COUNT(s) FROM LevelStorySubmission s WHERE s.activitySession.activity.id = :activityId")
    long countByActivityId(@Param("activityId") int activityId);


    @Query("""
        SELECT s FROM LevelStorySubmission s
        WHERE s.activitySession.session.child.id = :childId
        ORDER BY s.submittedAt DESC
    """)
    List<LevelStorySubmission> findByChildId(@Param("childId") int childId);

    @Query("SELECT COUNT(s) FROM LevelStorySubmission s WHERE s.activitySession.session.child.id = :childId")
    long countByChildId(@Param("childId") int childId);


    @Query("""
        SELECT s FROM LevelStorySubmission s
        WHERE s.activitySession.activity.id = :activityId
          AND s.activitySession.session.child.id = :childId
        ORDER BY s.submittedAt DESC
    """)
    List<LevelStorySubmission> findByActivityIdAndChildId(
            @Param("activityId") int activityId,
            @Param("childId") int childId);

    @Query("""
        SELECT COUNT(s) FROM LevelStorySubmission s
        WHERE s.activitySession.activity.id = :activityId
          AND s.activitySession.session.child.id = :childId
    """)
    long countByActivityIdAndChildId(
            @Param("activityId") int activityId,
            @Param("childId") int childId);
}