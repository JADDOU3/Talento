package org.example.backend.Dto.Order;

import lombok.Data;

@Data
public class OrderItemDTO {
    private int id;
    private int kitId;
    private String kitName;
    private double price;
    private int quantity;
}