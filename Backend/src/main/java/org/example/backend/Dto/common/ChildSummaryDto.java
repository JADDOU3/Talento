package org.example.backend.Dto.common;

import lombok.Data;
import org.example.backend.model.Child;
import org.example.backend.util.enums.Gender;

import java.time.LocalDateTime;

@Data
public class ChildSummaryDto {
    private int id;
    private String name;
    private int age;
    private Gender gender;
    private LocalDateTime dateOfBirth;
    private LocalDateTime createdAt;
    private boolean isSelected;

    public static ChildSummaryDto from(Child child) {
        if (child == null) return null;
        ChildSummaryDto dto = new ChildSummaryDto();
        dto.setId(child.getId());
        dto.setName(child.getName());
        dto.setAge(child.getAge());
        dto.setGender(child.getGender());
        dto.setDateOfBirth(child.getDateOfBirth());
        dto.setCreatedAt(child.getCreatedAt());
        dto.setSelected(child.isSelected());
        return dto;
    }
}
