package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.mindset.Mindset;

@Data
public class MindsetSummaryDto {
    private int id;
    private String name;
    private String description;

    public static MindsetSummaryDto from(Mindset mindset) {
        if (mindset == null) return null;
        MindsetSummaryDto dto = new MindsetSummaryDto();
        dto.setId(mindset.getId());
        dto.setName(mindset.getName());
        dto.setDescription(mindset.getDescription());
        return dto;
    }
}
