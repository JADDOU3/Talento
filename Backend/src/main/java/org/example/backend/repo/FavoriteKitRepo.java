package org.example.backend.repo;

import org.example.backend.model.FavoriteKit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FavoriteKitRepo extends JpaRepository<FavoriteKit, Integer> {
    List<FavoriteKit> findByParentId(int parentId);
    List<FavoriteKit> findByParentIdAndKitId(int parentId, int kitId);
}