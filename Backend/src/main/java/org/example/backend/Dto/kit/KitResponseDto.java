package org.example.backend.Dto.kit;

import lombok.Data;
import org.example.backend.Dto.common.MindsetSummaryDto;
import org.example.backend.model.Kit;
import org.example.backend.util.enums.Type;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class KitResponseDto {
    private int id;
    private String name;
    private String description;
    private double price;
    private LocalDateTime createdAt;
    private String imageURL;
    private int rating;
    private int age;
    private List<String> kitItems;
    private Type type;
    private MindsetSummaryDto mindset;

    public static KitResponseDto from(Kit kit) {
        if (kit == null) return null;
        KitResponseDto dto = new KitResponseDto();
        dto.setId(kit.getId());
        dto.setName(kit.getName());
        dto.setDescription(kit.getDescription());
        dto.setPrice(kit.getPrice());
        dto.setCreatedAt(kit.getCreatedAt());
        dto.setImageURL(kit.getImageURL());
        dto.setRating(kit.getRating());
        dto.setAge(kit.getAge());
        dto.setKitItems(kit.getKitItems());
        dto.setType(kit.getType());
        dto.setMindset(MindsetSummaryDto.from(kit.getMindset()));
        return dto;
    }
}
