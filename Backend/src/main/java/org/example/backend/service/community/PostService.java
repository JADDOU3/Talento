package org.example.backend.service.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreatePostDto;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.model.community.Media;
import org.example.backend.model.community.Post;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.community.MediaRepo;
import org.example.backend.repo.community.PostRepo;
import org.example.backend.service.ChildService;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostService {
    private final PostRepo postRepo;
    private final ChildRepo childRepo;
    private final KitRepo kitRepo;
    private final MediaRepo mediaRepo;
    private final ChildService childService;

    @Transactional
    public Post createPost(CreatePostDto dto) {
        Child child = childService.getSelectedChild();
        if (child == null) {
            throw new RuntimeException("No child selected for the current parent");
        }

        Post post = new Post();
        post.setContent(dto.getContent());
        post.setCreatedAt(LocalDateTime.now());
        post.setChild(child);

        if (dto.getKitId() != null) {
            Kit kit = kitRepo.findById(dto.getKitId())
                    .orElseThrow(() -> new RuntimeException("Kit not found"));
            post.setKit(kit);
        }

        Post savedPost = postRepo.save(post);

        if (dto.getMedia() != null) {
            List<Media> mediaList = dto.getMedia().stream().map(mDto -> {
                Media media = new Media();
                media.setType(mDto.getType());
                media.setUrl(mDto.getUrl());
                media.setPost(savedPost);
                return media;
            }).collect(Collectors.toList());
            mediaRepo.saveAll(mediaList);
            savedPost.setMedia(mediaList);
        }

        return savedPost;
    }

    public Page<Post> getAllPosts(Pageable pageable) {
        return postRepo.findAll(pageable);
    }

    public Post getPostById(int id) {
        return postRepo.findById(id).orElseThrow(() -> new RuntimeException("Post not found"));
    }

    public Page<Post> getPostsByChild(int childId, Pageable pageable) {
        return postRepo.findByChildId(childId, pageable);
    }

    public Page<Post> getPostsByKit(int kitId, Pageable pageable) {
        return postRepo.findByKitId(kitId, pageable);
    }

    public Page<Post> getPostsByMindset(int mindsetId, Pageable pageable) {
        return postRepo.findByKitMindsetId(mindsetId, pageable);
    }

    public Page<Post> getMyPosts(Pageable pageable) {
        Child child = childService.getSelectedChild();
        if (child == null) {
            throw new RuntimeException("No child selected for the current parent");
        }
        return postRepo.findByChildId(child.getId(), pageable);
    }

    @Transactional
    public void deletePost(int id) {
        postRepo.deleteById(id);
    }
}