package org.example.backend.Dto.roadmap;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class RoadmapResponseDto {
    private int kitId;
    private String kitName;
    private String kitImageURL;
    private List<RoadmapActivityDto> activities;
}

