package org.example.backend.service;

import org.example.backend.Dto.coin.CoinAwardResultDto;
import org.example.backend.model.Child;
import org.example.backend.model.CoinTransaction;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.CoinTransactionRepo;
import org.example.backend.util.enums.CoinReason;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

@Service
public class CoinService {

    @Autowired
    private ChildRepo childRepo;

    @Autowired
    private CoinTransactionRepo coinTransactionRepo;

    // once-per-day reasons — add more here as needed
    private static final int LOGIN_COOLDOWN_HOURS = 20;

    @Transactional
    public CoinAwardResultDto awardCoins(Child child, CoinReason reason) {
        return awardCoins(child, reason.getAmount(), reason);
    }

    // overload for MAZE_COIN_COLLECT where amount = perCoinValue * count
    @Transactional
    public CoinAwardResultDto awardCoins(Child child, int amount, CoinReason reason) {
        if (reason == CoinReason.LOGIN && alreadyAwardedRecently(child.getId(), reason, LOGIN_COOLDOWN_HOURS)) {
            return new CoinAwardResultDto(0, child.getCoinBalance());
        }

        child.setCoinBalance(child.getCoinBalance() + amount);
        childRepo.save(child);

        CoinTransaction tx = new CoinTransaction();
        tx.setChild(child);
        tx.setAmount(amount);
        tx.setReason(reason);
        tx.setCreatedAt(LocalDateTime.now());
        coinTransactionRepo.save(tx);

        return new CoinAwardResultDto(amount, child.getCoinBalance());
    }

    private boolean alreadyAwardedRecently(int childId, CoinReason reason, int cooldownHours) {
        Optional<CoinTransaction> last = coinTransactionRepo.findTopByChildIdAndReasonOrderByCreatedAtDesc(childId, reason);
        return last.filter(tx -> ChronoUnit.HOURS.between(tx.getCreatedAt(), LocalDateTime.now()) < cooldownHours).isPresent();
    }
}