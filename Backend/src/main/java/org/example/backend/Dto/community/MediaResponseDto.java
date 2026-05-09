package org.example.backend.Dto.community;

import lombok.AllArgsConstructor;
import lombok.Data;
import org.example.backend.util.enums.MediaType;

@Data
@AllArgsConstructor
public class MediaResponseDto {
    private int id;
    private MediaType type;
    private String url;
}
