package org.example.backend.Dto.parent;

import lombok.Data;

@Data
public class UpdateProfileDto {
    private String name;
    private String phone;
    private String location;
}