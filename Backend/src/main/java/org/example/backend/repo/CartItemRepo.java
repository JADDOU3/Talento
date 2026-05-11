package org.example.backend.repo;

import org.example.backend.model.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepo extends JpaRepository<CartItem, Integer> {
    List<CartItem> findByCartId(int cartId);
    void deleteByCartId(int cartId);
    Optional<CartItem> findByCartIdAndKitId(int cartId, int kitId);
}