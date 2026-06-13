package org.example.backend.Dto.activitySession;

import lombok.Data;
import org.example.backend.Dto.common.ActivitySummaryDto;
import org.example.backend.Dto.common.SessionSummaryDto;
import org.example.backend.model.activity.ActivitySession;
@Data
public class ActivitySessionResponseDto {
    private int id;
    private int orderIndex;
    private java.time.LocalDateTime startedAt;
    private java.time.LocalDateTime endedAt;
    private SessionSummaryDto session;
    private ActivitySummaryDto activity;

    public static ActivitySessionResponseDto from(ActivitySession activitySession, String coverImageUrl) {
        if (activitySession == null) return null;
        ActivitySessionResponseDto dto = new ActivitySessionResponseDto();
        dto.setId(activitySession.getId());
        dto.setOrderIndex(activitySession.getOrderIndex());
        dto.setStartedAt(activitySession.getStartedAt());
        dto.setEndedAt(activitySession.getEndedAt());
        dto.setSession(SessionSummaryDto.from(activitySession.getSession()));
        dto.setActivity(ActivitySummaryDto.from(activitySession.getActivity(), coverImageUrl));
        return dto;
    }
}
