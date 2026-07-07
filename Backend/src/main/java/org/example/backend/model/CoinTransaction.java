package org.example.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.CoinReason;

import java.time.LocalDateTime;

@Entity
@Table(name = "coin_transaction")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoinTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @ManyToOne
    @JoinColumn(name = "child_id")
    private Child child;

    private int amount;

    @Enumerated(EnumType.STRING)
    private CoinReason reason;

    private LocalDateTime createdAt;
}