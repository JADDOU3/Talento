package org.example.backend.Dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class CartDTO {
    private int id;
    private LocalDateTime createdAt;
    private List<CartItemDTO> items;
}