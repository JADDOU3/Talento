package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.activity.ActivitySession;

import java.time.LocalDateTime;

@Data
public class ActivitySessionSummaryDto {
    private int id;
    private int orderIndex;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer sessionId;
    private Integer activityId;

    public static ActivitySessionSummaryDto from(ActivitySession activitySession) {
        if (activitySession == null) return null;
        ActivitySessionSummaryDto dto = new ActivitySessionSummaryDto();
        dto.setId(activitySession.getId());
        dto.setOrderIndex(activitySession.getOrderIndex());
        dto.setStartedAt(activitySession.getStartedAt());
        dto.setEndedAt(activitySession.getEndedAt());
        dto.setSessionId(activitySession.getSession() != null ? activitySession.getSession().getId() : null);
        dto.setActivityId(activitySession.getActivity() != null ? activitySession.getActivity().getId() : null);
        return dto;
    }
}
