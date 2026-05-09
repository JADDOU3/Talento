package org.example.backend.Dto.CartItem;

import lombok.Data;

@Data
public class CreateCartItemDTO {
    private int kitId;
    private int quantity;
}