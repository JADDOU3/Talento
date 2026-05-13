package org.example.backend.Dto.community;

import lombok.Data;

@Data
public class PostLikeDto {
    private int postId;
    private Integer childId;
    private Integer parentId;
}
