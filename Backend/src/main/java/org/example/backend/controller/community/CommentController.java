package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreateCommentDto;
import org.example.backend.model.community.Comment;
import org.example.backend.service.community.CommentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/comments")
@RequiredArgsConstructor
public class CommentController {
    private final CommentService commentService;

    @PostMapping
    public ResponseEntity<Comment> createComment(@RequestBody CreateCommentDto dto) {
        return ResponseEntity.ok(commentService.createComment(dto));
    }

    @GetMapping("/post/{postId}")
    public ResponseEntity<List<Comment>> getCommentsByPost(@PathVariable int postId) {
        return ResponseEntity.ok(commentService.getCommentsByPost(postId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable int id) {
        commentService.deleteComment(id);
        return ResponseEntity.noContent().build();
    }
}
