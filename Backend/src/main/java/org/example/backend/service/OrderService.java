package org.example.backend.service;

import jakarta.transaction.Transactional;
import org.example.backend.Dto.Order.OrderDTO;
import org.example.backend.Dto.Order.OrderItemDTO;
import org.example.backend.model.*;
import org.example.backend.repo.OrderItemRepo;
import org.example.backend.repo.OrderRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class OrderService {

    @Autowired
    private OrderRepo orderRepo;
    @Autowired
    private OrderItemRepo orderItemRepo;
    @Autowired
    private CartService cartService;

    public List<OrderDTO> getAllOrders() {
        List<Order> orders=orderRepo.findAll();
        List<OrderDTO> dtos=new ArrayList<>();
        for (Order order : orders) {
            dtos.add(toOrderDTO(order));
        }
        return dtos;
    }

    public List<OrderDTO> getUserOrders() {
        int parentId=SecurityUtils.getCurrentUser().getId();
        List<Order> orders=orderRepo.findByParentId(parentId);
        List<OrderDTO> dtos=new ArrayList<>();
        for (Order order : orders) {
            dtos.add(toOrderDTO(order));
        }
        return dtos;
    }

    public OrderDTO getOrderById(int id) {
        int parentId=SecurityUtils.getCurrentUser().getId();
        Order order=orderRepo.findById(id).orElse(null);
        if (order==null) return null;
        if (order.getParent().getId()!=parentId) return null;
        return toOrderDTO(order);
    }

    @Transactional
    public void deleteOrder(int id) {
        Order order=orderRepo.findById(id).orElse(null);
        if (order==null) return;
        orderRepo.delete(order);
    }

    @Transactional
    public OrderDTO checkout() {
        Parent parent=SecurityUtils.getCurrentUser();
        List<CartItem> cartItems=cartService.getCartItems(parent.getId());
        if (cartItems==null || cartItems.isEmpty()) return null;

        Order order=new Order();
        order.setParent(parent);

        List<OrderItem> orderItems=new ArrayList<>();
        double total=0;

        for (CartItem item : cartItems) {
            OrderItem orderItem=new OrderItem();
            orderItem.setOrder(order);
            orderItem.setKit(item.getKit());
            orderItem.setQuantity(item.getQuantity());
            orderItem.setPrice(item.getKit().getPrice());
            total+=item.getKit().getPrice()*item.getQuantity();
            orderItems.add(orderItem);
        }

        order.setItems(orderItems);
        order.setTotalPrice(total);
        orderRepo.save(order);
        cartService.clearCart(parent.getId());
        return toOrderDTO(order);
    }

    private OrderDTO toOrderDTO(Order order) {
        OrderDTO dto=new OrderDTO();
        dto.setId(order.getId());
        dto.setTotalPrice(order.getTotalPrice());
        dto.setStatus(order.getStatus());
        dto.setCreatedAt(order.getCreatedAt());
        List<OrderItem> items=orderItemRepo.findByOrderId(order.getId());
        List<OrderItemDTO> itemDtos=new ArrayList<>();
        for (OrderItem item : items) {
            OrderItemDTO itemDto=new OrderItemDTO();
            itemDto.setId(item.getId());
            itemDto.setKitId(item.getKit().getId());
            itemDto.setKitName(item.getKit().getName());
            itemDto.setPrice(item.getPrice());
            itemDto.setQuantity(item.getQuantity());
            itemDtos.add(itemDto);
        }
        dto.setItems(itemDtos);
        return dto;
    }
}