package org.example.backend.Dto.session;

import lombok.Data;
import org.example.backend.Dto.common.ChildSummaryDto;
import org.example.backend.Dto.common.KitSummaryDto;
import org.example.backend.model.Session;

import java.time.LocalDateTime;

@Data
public class SessionResponseDto {
    private int id;
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;
    private ChildSummaryDto child;
    private KitSummaryDto kit;

    public static SessionResponseDto from(Session session) {
        if (session == null) return null;
        SessionResponseDto dto = new SessionResponseDto();
        dto.setId(session.getId());
        dto.setStartedAt(session.getStartedAt());
        dto.setEndedAt(session.getEndedAt());
        dto.setChild(ChildSummaryDto.from(session.getChild()));
        dto.setKit(KitSummaryDto.from(session.getKit()));
        return dto;
    }
}