package org.example.backend.controller;

import org.example.backend.Dto.Order.OrderDTO;
import org.example.backend.Dto.Order.OrderItemDTO;
import org.example.backend.service.OrderService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @GetMapping("/")
    public ResponseEntity<Page<OrderDTO>> getAllOrders(Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(orderService.getAllOrders(), pageable), HttpStatus.OK);
    }

    @GetMapping("/my")
    public ResponseEntity<Page<OrderDTO>> getUserOrders(Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(orderService.getUserOrders(), pageable), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrderDTO> getOrderById(@PathVariable int id) {
        OrderDTO order=orderService.getOrderById(id);
        if (order!=null)
            return new ResponseEntity<>(order, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("/checkout")
    public ResponseEntity<OrderDTO> checkout() {
        OrderDTO order=orderService.checkout();
        if (order!=null)
            return new ResponseEntity<>(order, HttpStatus.CREATED);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteOrder(@PathVariable int id) {
        orderService.deleteOrder(id);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @GetMapping("/{orderId}/items")
    public ResponseEntity<Page<OrderItemDTO>> getOrderItems(@PathVariable int orderId, Pageable pageable) {
        OrderDTO order=orderService.getOrderById(orderId);
        if (order==null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(order.getItems(), pageable), HttpStatus.OK);
    }
}