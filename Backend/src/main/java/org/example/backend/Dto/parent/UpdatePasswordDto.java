package org.example.backend.Dto.parent;

import lombok.Data;

@Data
public class UpdatePasswordDto {
    private String currentPassword;
    private String newPassword;
}