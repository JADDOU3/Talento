package org.example.backend.Dto.activity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Type;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateActivityDto {
    private int id;
    private String name;
    private String description;
    private String gameDescription;
    private String coverImageKey;
    private Type type;
    private Boolean voiceEnabled;
}
