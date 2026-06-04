package org.example.backend.Dto.event;

import lombok.Data;
import org.example.backend.model.event.Event;

import java.time.LocalDateTime;

@Data
public class EventResponseDto {
    private int id;
    private LocalDateTime createdAt;
    private String value;
    private Float duration;
    private Boolean success;
    private int attempts;
    private int childId;
    private int sessionId;
    private Integer activityId;
    private String eventType;

    public static EventResponseDto from(Event event) {
        if (event == null) return null;
        EventResponseDto dto = new EventResponseDto();
        dto.setId(event.getId());
        dto.setCreatedAt(event.getCreatedAt());
        dto.setValue(event.getValue());
        dto.setDuration(event.getDuration());
        dto.setSuccess(event.getSuccess());
        dto.setAttempts(event.getAttempts());
        dto.setChildId(event.getChild() != null ? event.getChild().getId() : 0);
        dto.setSessionId(event.getSession() != null ? event.getSession().getId() : 0);
        dto.setActivityId(event.getActivity() != null ? event.getActivity().getId() : null);
        dto.setEventType(event.getClass().getSimpleName());
        return dto;
    }
}
