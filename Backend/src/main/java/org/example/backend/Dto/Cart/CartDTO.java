package org.example.backend.Dto.Cart;

import lombok.Data;
import org.example.backend.Dto.CartItem.CartItemDTO;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CartDTO {
    private int id;
    private LocalDateTime createdAt;
    private List<CartItemDTO> items;
}