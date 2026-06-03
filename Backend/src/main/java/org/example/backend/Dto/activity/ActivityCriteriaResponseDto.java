package org.example.backend.Dto.activity;

import lombok.Data;
import org.example.backend.model.activity.ActivityCriteria;

@Data
public class ActivityCriteriaResponseDto {
    private int id;
    private Float weight;
    private int activityId;
    private int criteriaId;

    public static ActivityCriteriaResponseDto from(ActivityCriteria ac) {
        if (ac == null) return null;
        ActivityCriteriaResponseDto dto = new ActivityCriteriaResponseDto();
        dto.setId(ac.getId());
        dto.setWeight(ac.getWeight());
        dto.setActivityId(ac.getActivity() != null ? ac.getActivity().getId() : 0);
        dto.setCriteriaId(ac.getCriteria() != null ? ac.getCriteria().getId() : 0);
        return dto;
    }
}
