package org.example.backend.Dto.Favorite;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class FavoriteKitDto {
    private int id;
    private int kitId;
    private String kitName;
    private String kitImageURL;
    private double kitPrice;
    private int kitRating;
    private LocalDateTime createdAt;
}