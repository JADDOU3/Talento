package org.example.backend.Dto.Review;

import lombok.Data;

@Data
public class UpdateReviewDto {
    private int rating;
    private String comment;
}