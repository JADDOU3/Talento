package org.example.backend.repo.level;

import org.example.backend.model.level.Level;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface LevelRepo extends JpaRepository<Level, Integer> {

    List<Level> findByActivityIdOrderByLevelNumber(int activityId);
}