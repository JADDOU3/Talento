package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreatePostDto;
import org.example.backend.model.community.Post;
import org.example.backend.service.community.PostService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

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
    public ResponseEntity<List<Post>> getAllPosts() {
        return ResponseEntity.ok(postService.getAllPosts());
    }

    @GetMapping("/my")
    public ResponseEntity<List<Post>> getMyPosts() {
        return ResponseEntity.ok(postService.getMyPosts());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Post> getPostById(@PathVariable int id) {
        return ResponseEntity.ok(postService.getPostById(id));
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<Post>> getPostsByChild(@PathVariable int childId) {
        return ResponseEntity.ok(postService.getPostsByChild(childId));
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<List<Post>> getPostsByKit(@PathVariable int kitId) {
        return ResponseEntity.ok(postService.getPostsByKit(kitId));
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<List<Post>> getPostsByMindset(@PathVariable int mindsetId) {
        return ResponseEntity.ok(postService.getPostsByMindset(mindsetId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(@PathVariable int id) {
        postService.deletePost(id);
        return ResponseEntity.noContent().build();
    }
}
