package org.example.backend.Dto.Order;

import lombok.Data;
import org.example.backend.util.enums.OrderStatus;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class OrderDTO {
    private int id;
    private double totalPrice;
    private OrderStatus status;
    private LocalDateTime createdAt;
    private List<OrderItemDTO> items;
}