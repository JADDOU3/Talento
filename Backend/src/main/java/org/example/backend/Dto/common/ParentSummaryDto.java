package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.Parent;
import org.example.backend.util.enums.Gender;

import java.time.LocalDateTime;

@Data
public class ParentSummaryDto {
    private int id;
    private String name;
    private String email;
    private Gender gender;
    private String phone;
    private String location;
    private LocalDateTime createdAt;
    private boolean childModeEnabled;

    public static ParentSummaryDto from(Parent parent) {
        if (parent == null) return null;
        ParentSummaryDto dto = new ParentSummaryDto();
        dto.setId(parent.getId());
        dto.setName(parent.getName());
        dto.setEmail(parent.getEmail());
        dto.setGender(parent.getGender());
        dto.setPhone(parent.getPhone());
        dto.setLocation(parent.getLocation());
        dto.setCreatedAt(parent.getCreatedAt());
        dto.setChildModeEnabled(parent.isChildModeEnabled());
        return dto;
    }
}
