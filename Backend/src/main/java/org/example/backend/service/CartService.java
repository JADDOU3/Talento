package org.example.backend.service;

import jakarta.transaction.Transactional;
import org.example.backend.Dto.CartDTO;
import org.example.backend.Dto.CartItemDTO;
import org.example.backend.model.Cart;
import org.example.backend.model.CartItem;
import org.example.backend.model.User;
import org.example.backend.repo.CartItemRepo;
import org.example.backend.repo.CartRepo;
import org.example.backend.repo.KitRepo;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.ArrayList;
import java.util.List;

public class CartService {
    @Autowired
    private CartRepo cartRepo;
    @Autowired
    private CartItemRepo cartItemRepo;
    @Autowired
    private KitRepo kitRepo;

    public CartDTO createCart(int userId) {
        Cart existing = cartRepo.findByUserId(userId).orElse(null);
        if (existing!= null)
            return null;

        User user = new User();
        user.setId(userId);

        Cart cart = new Cart();
        cart.setUser(user);
        Cart saved = cartRepo.save(cart);

        CartDTO dto = new CartDTO();
        dto.setId(saved.getId());
        dto.setCreatedAt(saved.getCreatedAt());
        dto.setItems(List.of());
        return dto;
    }

    public CartDTO getCart(int userId) {
        Cart cart = cartRepo.findByUserId(userId).orElse(null);
        if (cart == null) return null;

        List<CartItem> items = cartItemRepo.findByCartId(cart.getId());
        List<CartItemDTO> itemDtos = new ArrayList<>();

        for (CartItem item : items) {
            CartItemDTO itemDto = new CartItemDTO();
            itemDto.setId(item.getId());
            itemDto.setKitId(item.getKit().getId());
            itemDto.setKitName(item.getKit().getName());
            itemDto.setKitPrice(item.getKit().getPrice());
            itemDto.setQuantity(item.getQuantity());
            itemDtos.add(itemDto);
        }

        CartDTO dto = new CartDTO();
        dto.setId(cart.getId());
        dto.setCreatedAt(cart.getCreatedAt());
        dto.setItems(itemDtos);

        return dto;
    }

    @Transactional
    public void clearCart(int userId) {
        Cart cart = cartRepo.findByUserId(userId).orElse(null);
        if (cart == null) return;
        cartItemRepo.deleteByCartId(cart.getId());
    }


}
