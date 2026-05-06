package org.example.backend.repo.community;

import org.example.backend.model.community.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PostRepo extends JpaRepository<Post, Integer> {
    Page<Post> findByChildId(int childId, Pageable pageable);
    Page<Post> findByKitId(int kitId, Pageable pageable);
    Page<Post> findByKitMindsetId(int mindsetId, Pageable pageable);
}
