package org.example.backend.Dto.coin;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoinAwardResultDto {
    private int coinsAwarded;
    private int newBalance;
}