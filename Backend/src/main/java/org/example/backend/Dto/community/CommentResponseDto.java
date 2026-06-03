package org.example.backend.Dto.community;

import lombok.Data;
import org.example.backend.Dto.common.ChildSummaryDto;
import org.example.backend.model.community.Comment;

import java.time.LocalDateTime;

@Data
public class CommentResponseDto {
    private int id;
    private String content;
    private LocalDateTime createdAt;
    private int postId;
    private ChildSummaryDto child;

    public static CommentResponseDto from(Comment comment) {
        if (comment == null) return null;
        CommentResponseDto dto = new CommentResponseDto();
        dto.setId(comment.getId());
        dto.setContent(comment.getContent());
        dto.setCreatedAt(comment.getCreatedAt());
        dto.setPostId(comment.getPost() != null ? comment.getPost().getId() : 0);
        dto.setChild(ChildSummaryDto.from(comment.getChild()));
        return dto;
    }
}
