package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.Kit;
import org.example.backend.util.enums.Type;

import java.time.LocalDateTime;

@Data
public class KitSummaryDto {
    private int id;
    private String name;
    private String description;
    private double price;
    private String imageURL;
    private Type type;
    private int rating;
    private int age;
    private LocalDateTime createdAt;

    public static KitSummaryDto from(Kit kit) {
        if (kit == null) return null;
        KitSummaryDto dto = new KitSummaryDto();
        dto.setId(kit.getId());
        dto.setName(kit.getName());
        dto.setDescription(kit.getDescription());
        dto.setPrice(kit.getPrice());
        dto.setImageURL(kit.getImageURL());
        dto.setType(kit.getType());
        dto.setRating(kit.getRating());
        dto.setAge(kit.getAge());
        dto.setCreatedAt(kit.getCreatedAt());
        return dto;
    }
}
