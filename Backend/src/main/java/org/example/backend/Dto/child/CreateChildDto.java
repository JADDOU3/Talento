package org.example.backend.Dto.child;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Gender;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class CreateChildDto {
        private String name;
        private LocalDateTime dateOfBirth;
        @Enumerated(EnumType.STRING)
        private Gender gender;
}
