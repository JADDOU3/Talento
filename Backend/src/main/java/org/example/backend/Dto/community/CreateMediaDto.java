package org.example.backend.Dto.community;

import lombok.Data;
import org.example.backend.util.enums.MediaType;

@Data
public class CreateMediaDto {
    private MediaType type;
    private String url;
}
