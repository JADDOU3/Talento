package org.example.backend.Dto.child;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.example.backend.Dto.common.ChildSummaryDto;
import org.example.backend.model.Child;

@Data
@EqualsAndHashCode(callSuper = true)
public class ChildResponseDto extends ChildSummaryDto {

    public static ChildResponseDto from(Child child) {
        if (child == null) return null;
        ChildResponseDto dto = new ChildResponseDto();
        ChildSummaryDto summary = ChildSummaryDto.from(child);
        dto.setId(summary.getId());
        dto.setName(summary.getName());
        dto.setAge(summary.getAge());
        dto.setGender(summary.getGender());
        dto.setDateOfBirth(summary.getDateOfBirth());
        dto.setCreatedAt(summary.getCreatedAt());
        dto.setSelected(summary.isSelected());
        return dto;
    }
}
