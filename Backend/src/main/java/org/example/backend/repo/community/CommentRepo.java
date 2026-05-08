package org.example.backend.repo.community;

import org.example.backend.model.community.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentRepo extends JpaRepository<Comment, Integer> {
    Page<Comment> findByPostId(int postId, Pageable pageable);
}
