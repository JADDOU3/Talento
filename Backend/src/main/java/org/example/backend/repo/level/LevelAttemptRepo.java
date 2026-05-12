package org.example.backend.repo.level;

import org.example.backend.model.level.LevelAttempt;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LevelAttemptRepo extends JpaRepository<LevelAttempt, Integer> {
    List<LevelAttempt> findByActivitySessionId(int activitySessionId);
    List<LevelAttempt> findByLevelId(int levelId);
}
