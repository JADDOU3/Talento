package org.example.backend.repo.community;

import org.example.backend.model.community.Post;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostRepo extends JpaRepository<Post, Integer> {
    List<Post> findByChildId(int childId);
    List<Post> findByKitId(int kitId);
    List<Post> findByKitMindsetId(int mindsetId);
}
