package org.example.backend.Dto.community;

import lombok.Data;

@Data
public class CreateCommentDto {
    private int postId;
    private Integer childId; // One of these must be present
    private Integer parentId;
    private String content;
}
