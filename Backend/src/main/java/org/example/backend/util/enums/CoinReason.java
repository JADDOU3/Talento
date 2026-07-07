package org.example.backend.util.enums;

public enum CoinReason {
    LEVEL_COMPLETE(10),
    DAILY_CHALLENGE(20),
    KIT_ADDED(15),
    MAZE_COIN_COLLECT(5),
    LOGIN(5);

    private final int amount;

    CoinReason(int amount) {
        this.amount = amount;
    }

    public int getAmount() {
        return amount;
    }
}