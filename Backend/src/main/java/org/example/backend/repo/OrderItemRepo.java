package org.example.backend.repo;

import org.example.backend.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrderItemRepo extends JpaRepository<OrderItem, Integer> {
    List<OrderItem> findByOrderId(int orderId);
}