package org.example.backend.Dto.coin;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.model.CoinTransaction;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoinTransactionDto {
    private int amount;
    private String reason;
    private LocalDateTime createdAt;

    public static CoinTransactionDto from(CoinTransaction tx) {
        return new CoinTransactionDto(tx.getAmount(), tx.getReason().name(), tx.getCreatedAt());
    }
}