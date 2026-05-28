package org.example.backend.Dto.level;

import lombok.Data;
import org.example.backend.model.level.LevelImage;

@Data
public class LevelImageResponseDto {
    private int id;
    private String s3Key;
    private String url;
    private String role;
    private String label;
    private String description;
    private Integer sortOrder;
    private String meta;

    public LevelImageResponseDto(LevelImage image, String url) {
        this.id = image.getId();
        this.s3Key = image.getS3Key();
        this.url = url;
        this.role = image.getRole();
        this.label = image.getLabel();
        this.description = image.getDescription();
        this.sortOrder = image.getSortOrder();
        this.meta = image.getMeta();
    }
}