package org.example.backend.service;

import jakarta.transaction.Transactional;
import org.example.backend.Dto.Cart.CartDTO;
import org.example.backend.Dto.CartItem.CartItemDTO;
import org.example.backend.Dto.CartItem.CreateCartItemDTO;
import org.example.backend.Dto.CartItem.UpdateCartItemDTO;
import org.example.backend.model.Cart;
import org.example.backend.model.CartItem;
import org.example.backend.model.Kit;
import org.example.backend.model.Parent;
import org.example.backend.repo.CartItemRepo;
import org.example.backend.repo.CartRepo;
import org.example.backend.repo.KitRepo;
import org.example.backend.service.community.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class CartService {

    @Autowired
    private CartRepo cartRepo;
    @Autowired
    private CartItemRepo cartItemRepo;
    @Autowired
    private KitRepo kitRepo;

    @Autowired
    private S3Service s3Service;

    private CartItemDTO toItemDto(CartItem item) {
        CartItemDTO dto = new CartItemDTO();
        dto.setId(item.getId());
        dto.setKitId(item.getKit().getId());
        dto.setKitName(item.getKit().getName());
        dto.setKitDescription(item.getKit().getDescription());
        dto.setKitPrice(item.getKit().getPrice());
        dto.setQuantity(item.getQuantity());

        String imageKey = item.getKit().getImageKey();
        dto.setKitImageURL(
                imageKey != null && !imageKey.isEmpty()
                        ? s3Service.generatePresignedUrl(imageKey)
                        : null
        );
        return dto;
    }

    private CartDTO toCartDto(Cart cart) {
        List<CartItem> items = cartItemRepo.findByCartId(cart.getId());
        List<CartItemDTO> itemDtos = new ArrayList<>();
        for (CartItem item : items) {
            itemDtos.add(toItemDto(item));
        }
        CartDTO dto = new CartDTO();
        dto.setId(cart.getId());
        dto.setCreatedAt(cart.getCreatedAt());
        dto.setItems(itemDtos);
        return dto;
    }


    public CartDTO createCart(int parentId) {
        Cart existing = cartRepo.findByParentId(parentId).orElse(null);
        if (existing != null) return null;

        Parent parent = new Parent();
        parent.setId(parentId);

        Cart cart = new Cart();
        cart.setParent(parent);
        Cart saved = cartRepo.save(cart);

        CartDTO dto = new CartDTO();
        dto.setId(saved.getId());
        dto.setCreatedAt(saved.getCreatedAt());
        dto.setItems(List.of());
        return dto;
    }

    public CartDTO getCart(int parentId) {
        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return null;
        return toCartDto(cart);
    }

    @Transactional
    public void clearCart(int parentId) {
        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return;
        cartItemRepo.deleteByCartId(cart.getId());
    }

    public CartDTO addItem(int parentId, CreateCartItemDTO dto) {
        if (dto.getQuantity() < 1) return null;

        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return null;

        Kit kit = kitRepo.findById(dto.getKitId()).orElse(null);
        if (kit == null) return null;

        CartItem existingItem = cartItemRepo.findByCartIdAndKitId(cart.getId(), kit.getId()).orElse(null);
        if (existingItem != null) {
            existingItem.setQuantity(existingItem.getQuantity() + dto.getQuantity());
            cartItemRepo.save(existingItem);
        } else {
            CartItem newItem = new CartItem();
            newItem.setCart(cart);
            newItem.setKit(kit);
            newItem.setQuantity(dto.getQuantity());
            cartItemRepo.save(newItem);
        }

        return toCartDto(cart);
    }

    public CartDTO updateItem(int parentId, int itemId, UpdateCartItemDTO dto) {
        if (dto.getQuantity() < 1) return null;

        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return null;

        CartItem item = cartItemRepo.findById(itemId).orElse(null);
        if (item == null) return null;
        if (item.getCart().getId() != cart.getId()) return null;

        item.setQuantity(dto.getQuantity());
        cartItemRepo.save(item);

        return toCartDto(cart);
    }

    @Transactional
    public CartDTO removeItem(int parentId, int itemId) {
        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return null;

        CartItem item = cartItemRepo.findById(itemId).orElse(null);
        if (item == null) return null;
        if (item.getCart().getId() != cart.getId()) return null;

        cartItemRepo.delete(item);

        return toCartDto(cart);
    }

    public List<CartItemDTO> getItems(int parentId) {
        Cart cart = cartRepo.findByParentId(parentId).orElse(null);
        if (cart == null) return null;

        List<CartItem> items = cartItemRepo.findByCartId(cart.getId());
        List<CartItemDTO> itemDtos = new ArrayList<>();
        for (CartItem item : items) {
            itemDtos.add(toItemDto(item));
        }
        return itemDtos;
    }
    public List<CartItem> getCartItems(int parentId) {
        Cart cart=cartRepo.findByParentId(parentId).orElse(null);
        if (cart==null) return null;
        return cartItemRepo.findByCartId(cart.getId());
    }
}