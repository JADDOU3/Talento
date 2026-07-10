package org.example.backend.repo;

import org.example.backend.model.CoinTransaction;
import org.example.backend.util.enums.CoinReason;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface CoinTransactionRepo extends JpaRepository<CoinTransaction, Integer> {

    List<CoinTransaction> findByChildIdOrderByCreatedAtDesc(int childId);

    Optional<CoinTransaction> findTopByChildIdAndReasonOrderByCreatedAtDesc(int childId, CoinReason reason);
}