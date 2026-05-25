package org.example.backend.Dto.level;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelImageDto {
    private String s3Key;
    private String role;
    private String label;
    private String description;
    private Integer sortOrder;
    private String meta;
}

