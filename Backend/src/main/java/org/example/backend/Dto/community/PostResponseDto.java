package org.example.backend.Dto.community;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.model.community.Comment;
import org.example.backend.model.community.Post;
import org.example.backend.model.community.PostLike;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
public class PostResponseDto {

    private int id;
    private String content;
    private LocalDateTime createdAt;
    private Child child;
    private Kit kit;
    private List<Comment> comments;
    private List<PostLike> likes;


    private List<MediaResponseDto> media;
    public PostResponseDto(Post post, List<MediaResponseDto> media) {
        this.id = post.getId();
        this.content = post.getContent();
        this.createdAt = post.getCreatedAt();
        this.child = post.getChild();
        this.kit = post.getKit();
        this.comments = post.getComments();
        this.likes = post.getLikes();
        this.media = media;
    }
}