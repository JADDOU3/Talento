package org.example.backend.Dto.level;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateLevelDto {
    private Integer levelNumber;
    private Integer difficulty;
    private String description;
}
