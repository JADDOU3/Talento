package org.example.backend.repo;

import org.example.backend.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ReviewRepo extends JpaRepository<Review, Integer> {
    List<Review> findByKitId(int kitId);
    List<Review> findByParentId(int parentId);
    List<Review> findByParentIdAndKitId(int parentId, int kitId);}