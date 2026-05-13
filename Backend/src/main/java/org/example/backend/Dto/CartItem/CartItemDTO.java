package org.example.backend.Dto.CartItem;

import lombok.Data;

@Data
public class CartItemDTO {
    private int id;
    private int kitId;
    private String kitName;
    private double kitPrice;
    private int quantity;
    private String kitImageURL;
    private String kitDescription;
}