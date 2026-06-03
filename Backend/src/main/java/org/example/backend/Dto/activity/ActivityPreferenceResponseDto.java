package org.example.backend.Dto.activity;

import lombok.Data;
import org.example.backend.model.activity.ActivityPreference;

import java.time.LocalDateTime;

@Data
public class ActivityPreferenceResponseDto {
    private int id;
    private int timesStarted;
    private int timesRepeated;
    private int timesCompleted;
    private LocalDateTime lastPlayed;
    private int childId;
    private int activityId;

    public static ActivityPreferenceResponseDto from(ActivityPreference preference) {
        if (preference == null) return null;
        ActivityPreferenceResponseDto dto = new ActivityPreferenceResponseDto();
        dto.setId(preference.getId());
        dto.setTimesStarted(preference.getTimesStarted());
        dto.setTimesRepeated(preference.getTimesRepeated());
        dto.setTimesCompleted(preference.getTimesCompleted());
        dto.setLastPlayed(preference.getLastPlayed());
        dto.setChildId(preference.getChild() != null ? preference.getChild().getId() : 0);
        dto.setActivityId(preference.getActivity() != null ? preference.getActivity().getId() : 0);
        return dto;
    }
}
