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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CommentService {
    private final CommentRepo commentRepo;
    private final PostRepo postRepo;
    private final ChildRepo childRepo;
    private final ParentRepo parentRepo;

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

    public List<Comment> getCommentsByPost(int postId) {
        return commentRepo.findByPostId(postId);
    }

    @Transactional
    public void deleteComment(int id) {
        commentRepo.deleteById(id);
    }
}
