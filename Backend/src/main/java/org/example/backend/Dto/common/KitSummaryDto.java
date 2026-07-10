package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.Kit;
import org.example.backend.service.community.S3Service;
import org.example.backend.util.enums.Type;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Data
@Component
public class KitSummaryDto {

    private static S3Service s3Service;

    @Autowired
    public void setS3Service(S3Service s3Service) {
        KitSummaryDto.s3Service = s3Service;
    }

    private int id;
    private String name;
    private String description;
    private double price;
    private String imageKey;
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
        dto.setImageKey(kit.getImageKey());
        dto.setImageURL(
                kit.getImageKey() != null && !kit.getImageKey().isEmpty() && s3Service != null
                        ? s3Service.generatePresignedUrl(kit.getImageKey())
                        : null
        );
        dto.setType(kit.getType());
        dto.setRating(kit.getRating());
        dto.setAge(kit.getAge());
        dto.setCreatedAt(kit.getCreatedAt());
        return dto;
    }
}