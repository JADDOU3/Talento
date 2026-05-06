package org.example.backend.Dto;

import lombok.Data;

@Data
public class CreateCartItemDTO {
    private int kitId;
    private int quantity;
}