package org.example.backend.Dto;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Gender;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChildUpdateDto {
    private int id;
    private String name;
    private LocalDateTime dateOfBirth;
    @Enumerated(EnumType.STRING)
    private Gender gender;
}
