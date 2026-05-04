package org.example.backend.Dto.criteria;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateCriteriaDto {
    private String name;
    private Float weight;
    private Integer mindsetId;
}
