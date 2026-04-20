package org.example.backend.Dto;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;
import org.example.backend.util.Mindset;
import org.example.backend.util.Type;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class KitDto {
    private String name;
    @Enumerated(EnumType.STRING)
    private Type type;
    @Enumerated(EnumType.STRING)
    private Mindset mindset;
    private String description;
    private double price;
    private int childId;

}
