package org.example.backend.repo.level;

import org.example.backend.model.level.LevelImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LevelImageRepo extends JpaRepository<LevelImage, Integer> {
    List<LevelImage> findByLevel_Id(int levelId);
}