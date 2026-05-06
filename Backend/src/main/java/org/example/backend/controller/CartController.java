package org.example.backend.controller;


import org.example.backend.Dto.Cart.CartDTO;
import org.example.backend.Dto.CartItem.CartItemDTO;
import org.example.backend.Dto.CartItem.CreateCartItemDTO;
import org.example.backend.Dto.CartItem.UpdateCartItemDTO;
import org.example.backend.service.CartService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequestMapping("/api/cart")
@RestController
public class CartController {

    @Autowired
    private CartService cartService;

    @PostMapping("/")
    public ResponseEntity<CartDTO> createCart() {
        int userId = SecurityUtils.getCurrentUser().getId();
        CartDTO cart = cartService.createCart(userId);
        if (cart != null)
            return new ResponseEntity<>(cart, HttpStatus.CREATED);
        return new ResponseEntity<>(HttpStatus.CONFLICT);
    }

    @GetMapping("/")
    public ResponseEntity<CartDTO> getCart() {
        int userId = SecurityUtils.getCurrentUser().getId();
        CartDTO cart = cartService.getCart(userId);
        if (cart != null)
            return new ResponseEntity<>(cart, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/")
    public ResponseEntity<Void> clearCart() {
        int userId = SecurityUtils.getCurrentUser().getId();
        cartService.clearCart(userId);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @PostMapping("/items")
    public ResponseEntity<CartDTO> addItem(@RequestBody CreateCartItemDTO dto) {
        int userId = SecurityUtils.getCurrentUser().getId();
        CartDTO cart = cartService. addItem(userId, dto);
        if (cart != null)
            return new ResponseEntity<>(cart, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    @PutMapping("/items/{itemId}")
    public ResponseEntity<CartDTO> updateItem(@PathVariable int itemId, @RequestBody UpdateCartItemDTO dto) {
        int parentId = SecurityUtils.getCurrentUser().getId();
        CartDTO cart = cartService.updateItem(parentId, itemId, dto);
        if (cart != null)
            return new ResponseEntity<>(cart, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<CartDTO> removeItem(@PathVariable int itemId) {
        int parentId = SecurityUtils.getCurrentUser().getId();
        CartDTO cart = cartService.removeItem(parentId, itemId);
        if (cart != null)
            return new ResponseEntity<>(cart, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @GetMapping("/items")
    public ResponseEntity<List<CartItemDTO>> getItems() {
        int parentId = SecurityUtils.getCurrentUser().getId();
        List<CartItemDTO> items = cartService.getItems(parentId);
        if (items != null)
            return new ResponseEntity<>(items, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}