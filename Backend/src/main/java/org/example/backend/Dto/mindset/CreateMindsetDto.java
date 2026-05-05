package org.example.backend.Dto.mindset;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateMindsetDto {
    private String name;
    private String description;
}
