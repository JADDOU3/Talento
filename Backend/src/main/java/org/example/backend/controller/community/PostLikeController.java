package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.PostLikeDto;
import org.example.backend.service.community.PostLikeService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/likes")
@RequiredArgsConstructor
public class PostLikeController {
    private final PostLikeService postLikeService;

    @PostMapping("/toggle")
    public ResponseEntity<String> toggleLike(@RequestBody PostLikeDto dto) {
        return ResponseEntity.ok(postLikeService.toggleLike(dto));
    }

    @GetMapping("/post/{postId}/count")
    public ResponseEntity<Long> getLikeCount(@PathVariable int postId) {
        return ResponseEntity.ok(postLikeService.getLikeCount(postId));
    }
}
