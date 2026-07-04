package org.example.backend.Dto.roadmap;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateRoadmapCardDto {
    private int kitId;
    private int activityId;
    private int sortOrder;
    private Integer levelFrom; // null = all levels
    private Integer levelTo;   // null = all levels
}