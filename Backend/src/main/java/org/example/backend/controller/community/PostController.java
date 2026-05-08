package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreatePostDto;
import org.example.backend.model.community.Post;
import org.example.backend.service.community.PostService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {
    private final PostService postService;

    @PostMapping
    public ResponseEntity<Post> createPost(@RequestBody CreatePostDto dto) {
        return ResponseEntity.ok(postService.createPost(dto));
    }

    @GetMapping
    public ResponseEntity<Page<Post>> getAllPosts(
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(postService.getAllPosts(pageable));
    }

    @GetMapping("/my")
    public ResponseEntity<Page<Post>> getMyPosts(
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(postService.getMyPosts(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Post> getPostById(@PathVariable int id) {
        return ResponseEntity.ok(postService.getPostById(id));
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<Page<Post>> getPostsByChild(
            @PathVariable int childId,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(postService.getPostsByChild(childId, pageable));
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<Page<Post>> getPostsByKit(
            @PathVariable int kitId,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(postService.getPostsByKit(kitId, pageable));
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<Post>> getPostsByMindset(
            @PathVariable int mindsetId,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(postService.getPostsByMindset(mindsetId, pageable));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable int id) {
        postService.deletePost(id);
        return ResponseEntity.noContent().build();
    }
}