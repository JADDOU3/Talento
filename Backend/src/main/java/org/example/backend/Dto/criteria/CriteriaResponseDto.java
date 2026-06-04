package org.example.backend.Dto.criteria;

import lombok.Data;
import org.example.backend.model.mindset.Criteria;

@Data
public class CriteriaResponseDto {
    private int id;
    private String name;
    private Float weight;
    private int mindsetId;

    public static CriteriaResponseDto from(Criteria criteria) {
        if (criteria == null) return null;
        CriteriaResponseDto dto = new CriteriaResponseDto();
        dto.setId(criteria.getId());
        dto.setName(criteria.getName());
        dto.setWeight(criteria.getWeight());
        dto.setMindsetId(criteria.getMindset() != null ? criteria.getMindset().getId() : 0);
        return dto;
    }
}
