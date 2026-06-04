package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.Session;

import java.time.LocalDateTime;

@Data
public class SessionSummaryDto {
    private int id;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private Integer childId;
    private Integer kitId;

    public static SessionSummaryDto from(Session session) {
        if (session == null) return null;
        SessionSummaryDto dto = new SessionSummaryDto();
        dto.setId(session.getId());
        dto.setStartedAt(session.getStartedAt());
        dto.setEndedAt(session.getEndedAt());
        dto.setChildId(session.getChild() != null ? session.getChild().getId() : null);
        dto.setKitId(session.getKit() != null ? session.getKit().getId() : null);
        return dto;
    }
}
