package org.example.backend.Dto.mindset;

import lombok.Data;
import org.example.backend.model.mindset.Mindset;

@Data
public class MindsetResponseDto {
    private int id;
    private String name;
    private String description;

    public static MindsetResponseDto from(Mindset mindset) {
        if (mindset == null) return null;
        MindsetResponseDto dto = new MindsetResponseDto();
        dto.setId(mindset.getId());
        dto.setName(mindset.getName());
        dto.setDescription(mindset.getDescription());
        return dto;
    }
}
