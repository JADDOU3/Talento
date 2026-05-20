package org.example.backend.Dto.activity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Type;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateActivityDto {
    private String name;
    private String description;
    private Type type;
    private Boolean voiceEnabled;
}
