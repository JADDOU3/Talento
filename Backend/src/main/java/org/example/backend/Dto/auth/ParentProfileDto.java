package org.example.backend.Dto.auth;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.example.backend.Dto.common.ParentSummaryDto;
import org.example.backend.model.Parent;

@Data
@EqualsAndHashCode(callSuper = true)
public class ParentProfileDto extends ParentSummaryDto {

    public static ParentProfileDto from(Parent parent) {
        if (parent == null) return null;
        ParentProfileDto dto = new ParentProfileDto();
        ParentSummaryDto summary = ParentSummaryDto.from(parent);
        dto.setId(summary.getId());
        dto.setName(summary.getName());
        dto.setEmail(summary.getEmail());
        dto.setGender(summary.getGender());
        dto.setPhone(summary.getPhone());
        dto.setLocation(summary.getLocation());
        dto.setCreatedAt(summary.getCreatedAt());
        dto.setChildModeEnabled(summary.isChildModeEnabled());
        return dto;
    }
}
