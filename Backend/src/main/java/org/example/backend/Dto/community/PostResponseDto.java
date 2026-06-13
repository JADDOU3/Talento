package org.example.backend.Dto.community;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.Dto.common.ChildSummaryDto;
import org.example.backend.Dto.common.KitSummaryDto;
import org.example.backend.model.community.Post;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
public class PostResponseDto {

    private int id;
    private String content;
    private LocalDateTime createdAt;
    private ChildSummaryDto child;
    private KitSummaryDto kit;
    private List<CommentResponseDto> comments;
    private List<PostLikeResponseDto> likes;
    private List<MediaResponseDto> media;

    public PostResponseDto(Post post, List<MediaResponseDto> media) {
        this.id = post.getId();
        this.content = post.getContent();
        this.createdAt = post.getCreatedAt();
        this.child = ChildSummaryDto.from(post.getChild());
        this.kit = KitSummaryDto.from(post.getKit());
        this.comments = post.getComments() != null
                ? post.getComments().stream().map(CommentResponseDto::from).collect(Collectors.toList())
                : List.of();
        this.likes = post.getLikes() != null
                ? post.getLikes().stream().map(PostLikeResponseDto::from).collect(Collectors.toList())
                : List.of();
        this.media = media;
    }
}
