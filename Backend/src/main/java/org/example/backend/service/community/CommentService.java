package org.example.backend.service.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreateCommentDto;
import org.example.backend.model.Child;
import org.example.backend.model.Parent;
import org.example.backend.model.community.Comment;
import org.example.backend.model.community.Post;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.ParentRepo;
import org.example.backend.repo.community.CommentRepo;
import org.example.backend.repo.community.PostRepo;
import org.example.backend.service.ChildService;
import org.example.backend.util.SecurityUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepo commentRepo;
    private final PostRepo postRepo;
    private final ChildRepo childRepo;
    private final ParentRepo parentRepo;
    private final ChildService childService;

    @Transactional
    public Comment createComment(CreateCommentDto dto) {
        Post post = postRepo.findById(dto.getPostId())
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Comment comment = new Comment();
        comment.setContent(dto.getContent());
        comment.setCreatedAt(LocalDateTime.now());
        comment.setPost(post);

        if (dto.getChildId() != null) {
            Child child = childRepo.findById(dto.getChildId())
                    .orElseThrow(() -> new RuntimeException("Child not found"));
            comment.setChild(child);
        } else if (dto.getParentId() != null) {
            Parent parent = parentRepo.findById(dto.getParentId())
                    .orElseThrow(() -> new RuntimeException("Parent not found"));
            comment.setParent(parent);
        } else {
            throw new RuntimeException("Either childId or parentId must be provided");
        }

        return commentRepo.save(comment);
    }

    public Page<Comment> getCommentsByPost(int postId, Pageable pageable) {
        return commentRepo.findByPostId(postId, pageable);
    }

    @Transactional
    public void deleteComment(int id) {
        Comment comment = commentRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Comment not found"));
        Parent parent = SecurityUtils.getCurrentUser();
        if (comment.getParent() == null || comment.getParent().getId() != parent.getId()) {
            throw new RuntimeException("Not authorized to delete this comment");
        }
        commentRepo.deleteById(id);
    }
}