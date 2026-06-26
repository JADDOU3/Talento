package org.example.backend.repo;

import org.example.backend.model.RoadmapCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RoadmapCardRepo extends JpaRepository<RoadmapCard, Integer> {
    List<RoadmapCard> findByKitIdOrderBySortOrder(int kitId);
}