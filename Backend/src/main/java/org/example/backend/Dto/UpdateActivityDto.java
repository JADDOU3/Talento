package org.example.backend.Dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.example.backend.util.Type;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateActivityDto {
    private int id;
    private String name;
    private String description;
    private Type type;
}
