package org.example.backend.repo.community;

import org.example.backend.model.community.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PostLikeRepo extends JpaRepository<PostLike, Integer> {
    Optional<PostLike> findByPostIdAndChildId(int postId, int childId);
    Optional<PostLike> findByPostIdAndParentId(int postId, int parentId);
    long countByPostId(int postId);
}
