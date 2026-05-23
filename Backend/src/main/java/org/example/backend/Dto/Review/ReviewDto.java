package org.example.backend.Dto.Review;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ReviewDto {
    private int id;
    private int kitId;
    private String kitName;
    private int parentId;
    private String parentName;
    private int rating;
    private String comment;
    private LocalDateTime createdAt;
}