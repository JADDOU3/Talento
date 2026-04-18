package org.example.backend.Dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.example.backend.util.Type;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateActivityDto {
    private String name;
    private String description;
    private Type type;
}
