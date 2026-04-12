package org.example.backend.Dto;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class ChildDto {
        private String name;
        private int age;
        @Enumerated(EnumType.STRING)
        private Gender gender;
        private int userId;
}
