package org.example.backend.service.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.CreatePostDto;
import org.example.backend.Dto.community.MediaResponseDto;
import org.example.backend.Dto.community.PostResponseDto;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.model.Parent;
import org.example.backend.model.community.Media;
import org.example.backend.model.community.Post;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.community.MediaRepo;
import org.example.backend.repo.community.PostLikeRepo;
import org.example.backend.repo.community.PostRepo;
import org.example.backend.service.ChildService;
import org.example.backend.util.SecurityUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Collections;
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
    private final S3Service s3Service;
    private final PostLikeRepo postLikeRepo;

    @Transactional
    public PostResponseDto createPost(CreatePostDto dto) {
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

        List<Media> mediaList = Collections.emptyList();
        if (dto.getMedia() != null && !dto.getMedia().isEmpty()) {
            mediaList = dto.getMedia().stream().map(mDto -> {
                Media media = new Media();
                media.setType(mDto.getType());
                media.setS3Key(mDto.getS3Key());
                media.setPost(savedPost);
                return media;
            }).collect(Collectors.toList());
            mediaRepo.saveAll(mediaList);
            savedPost.setMedia(mediaList);
        }

        return toResponseDto(savedPost);
    }

    public Page<PostResponseDto> getAllPosts(Pageable pageable) {
        return postRepo.findAll(pageable).map(this::toResponseDto);
    }

    public PostResponseDto getPostById(int id) {
        Post post = postRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Post not found"));
        return toResponseDto(post);
    }

    public Page<PostResponseDto> getPostsByChild(int childId, Pageable pageable) {
        return postRepo.findByChildId(childId, pageable).map(this::toResponseDto);
    }

    public Page<PostResponseDto> getPostsByKit(int kitId, Pageable pageable) {
        return postRepo.findByKitId(kitId, pageable).map(this::toResponseDto);
    }

    public Page<PostResponseDto> getPostsByMindset(int mindsetId, Pageable pageable) {
        return postRepo.findByKitMindsetId(mindsetId, pageable).map(this::toResponseDto);
    }

    public Page<PostResponseDto> getMyPosts(Pageable pageable) {
        Child child = childService.getSelectedChild();
        if (child == null) {
            throw new RuntimeException("No child selected for the current parent");
        }
        return postRepo.findByChildId(child.getId(), pageable).map(this::toResponseDto);
    }

    @Transactional
    public void deletePost(int id) {
        Post post = postRepo.findById(id)
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Parent parent = SecurityUtils.getCurrentUser();
        boolean isOwner = post.getChild() != null
                && post.getChild().getParent().getId() == parent.getId();

        if (!isOwner) throw new RuntimeException("Not authorized to delete this post");

        if (post.getMedia() != null) {
            post.getMedia().forEach(media -> s3Service.deleteFile(media.getS3Key()));
        }
        postRepo.deleteById(id);
    }

    private PostResponseDto toResponseDto(Post post) {
        List<MediaResponseDto> mediaDtos = Collections.emptyList();
        if (post.getMedia() != null) {
            mediaDtos = post.getMedia().stream()
                    .map(m -> new MediaResponseDto(
                            m.getId(),
                            m.getType(),
                            s3Service.generatePresignedUrl(m.getS3Key())
                    ))
                    .collect(Collectors.toList());
        }

        boolean likedByCurrentUser = false;
        try {
            Parent parent = SecurityUtils.getCurrentUser();
            likedByCurrentUser = postLikeRepo.existsByPostIdAndParentId(post.getId(), parent.getId());
        } catch (Exception e) {
            likedByCurrentUser = false;
        }

        return new PostResponseDto(post, mediaDtos, likedByCurrentUser);
    }
}