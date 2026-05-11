package org.example.backend.Dto.community;

import lombok.Data;
import org.example.backend.util.enums.MediaType;

import java.util.List;

@Data
public class CreatePostDto {

    private String content;
    private Integer kitId;
    private List<MediaDto> media;

    @Data
    public static class MediaDto {
        private MediaType type;
        private String s3Key;
    }
}