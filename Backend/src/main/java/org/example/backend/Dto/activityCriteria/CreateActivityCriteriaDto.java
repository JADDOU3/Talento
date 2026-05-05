package org.example.backend.Dto.activityCriteria;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateActivityCriteriaDto {
    private Float weight;
    private Integer activityId;
    private Integer criteriaId;
}
