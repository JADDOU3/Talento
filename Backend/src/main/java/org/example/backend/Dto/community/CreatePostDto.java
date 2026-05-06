package org.example.backend.Dto.community;

import lombok.Data;
import java.util.List;

@Data
public class CreatePostDto {
    private int childId;
    private Integer kitId;
    private String content;
    private List<CreateMediaDto> media;
}
