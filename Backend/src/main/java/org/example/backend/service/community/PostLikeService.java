package org.example.backend.service.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.community.PostLikeDto;
import org.example.backend.model.Child;
import org.example.backend.model.Parent;
import org.example.backend.model.community.Post;
import org.example.backend.model.community.PostLike;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.ParentRepo;
import org.example.backend.repo.community.PostLikeRepo;
import org.example.backend.repo.community.PostRepo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PostLikeService {
    private final PostLikeRepo postLikeRepo;
    private final PostRepo postRepo;
    private final ChildRepo childRepo;
    private final ParentRepo parentRepo;

    @Transactional
    public String toggleLike(PostLikeDto dto) {
        Post post = postRepo.findById(dto.getPostId())
                .orElseThrow(() -> new RuntimeException("Post not found"));

        Optional<PostLike> existingLike;
        if (dto.getChildId() != null) {
            existingLike = postLikeRepo.findByPostIdAndChildId(dto.getPostId(), dto.getChildId());
        } else if (dto.getParentId() != null) {
            existingLike = postLikeRepo.findByPostIdAndParentId(dto.getPostId(), dto.getParentId());
        } else {
            throw new RuntimeException("Either childId or parentId must be provided");
        }

        if (existingLike.isPresent()) {
            postLikeRepo.delete(existingLike.get());
            return "Unliked";
        } else {
            PostLike like = new PostLike();
            like.setPost(post);
            if (dto.getChildId() != null) {
                Child child = childRepo.findById(dto.getChildId())
                        .orElseThrow(() -> new RuntimeException("Child not found"));
                like.setChild(child);
            } else {
                Parent parent = parentRepo.findById(dto.getParentId())
                        .orElseThrow(() -> new RuntimeException("Parent not found"));
                like.setParent(parent);
            }
            postLikeRepo.save(like);
            return "Liked";
        }
    }

    public long getLikeCount(int postId) {
        return postLikeRepo.countByPostId(postId);
    }
}
