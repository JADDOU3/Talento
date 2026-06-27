package org.example.backend.Dto.kit;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Type;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateKitDto {
    private String name;
    @Enumerated(EnumType.STRING)
    private Type type;
    private Integer mindsetId;
    private String description;
    private Double price;
    private String imageKey;
    private List<String> kitItems;
    private Integer rating;
    private Integer age;
}
