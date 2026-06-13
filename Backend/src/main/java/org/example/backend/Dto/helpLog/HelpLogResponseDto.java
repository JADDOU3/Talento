package org.example.backend.Dto.helpLog;

import lombok.Data;
import org.example.backend.model.HelpLog;
import org.example.backend.util.enums.HelpLevel;

import java.time.LocalDateTime;

@Data
public class HelpLogResponseDto {
    private int id;
    private HelpLevel helpLevel;
    private LocalDateTime createdAt;
    private Integer activitySessionId;

    public static HelpLogResponseDto from(HelpLog helpLog) {
        if (helpLog == null) return null;
        HelpLogResponseDto dto = new HelpLogResponseDto();
        dto.setId(helpLog.getId());
        dto.setHelpLevel(helpLog.getHelpLevel());
        dto.setCreatedAt(helpLog.getCreatedAt());
        dto.setActivitySessionId(helpLog.getActivitySession() != null ? helpLog.getActivitySession().getId() : null);
        return dto;
    }
}
