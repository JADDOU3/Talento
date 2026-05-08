package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreateCommentDto;
import org.example.backend.model.community.Comment;
import org.example.backend.service.community.CommentService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
    public ResponseEntity<Page<Comment>> getCommentsByPost(
            @PathVariable int postId,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.ASC) Pageable pageable) {
        return ResponseEntity.ok(commentService.getCommentsByPost(postId, pageable));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteComment(@PathVariable int id) {
        commentService.deleteComment(id);
        return ResponseEntity.noContent().build();
    }
}