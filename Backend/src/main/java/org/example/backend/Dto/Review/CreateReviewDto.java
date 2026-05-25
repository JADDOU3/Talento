package org.example.backend.Dto.Review;

import lombok.Data;

@Data
public class CreateReviewDto {
    private int kitId;
    private int rating;
    private String comment;
}