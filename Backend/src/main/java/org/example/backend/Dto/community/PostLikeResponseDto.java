package org.example.backend.Dto.community;

import lombok.Data;
import org.example.backend.Dto.common.ChildSummaryDto;
import org.example.backend.model.community.PostLike;

@Data
public class PostLikeResponseDto {
    private int id;
    private int postId;
    private ChildSummaryDto child;

    public static PostLikeResponseDto from(PostLike like) {
        if (like == null) return null;
        PostLikeResponseDto dto = new PostLikeResponseDto();
        dto.setId(like.getId());
        dto.setPostId(like.getPost() != null ? like.getPost().getId() : 0);
        dto.setChild(ChildSummaryDto.from(like.getChild()));
        return dto;
    }
}
