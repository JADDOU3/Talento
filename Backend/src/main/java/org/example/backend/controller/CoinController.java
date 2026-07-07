package org.example.backend.controller;

import org.example.backend.Dto.coin.CoinTransactionDto;
import org.example.backend.model.Child;
import org.example.backend.service.ChildService;
import org.example.backend.service.CoinService;
import org.example.backend.util.enums.CoinReason;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/api/coins")
@RestController
public class CoinController {

    @Autowired
    private CoinService coinService;

    @Autowired
    private ChildService childService;

    @Autowired
    private org.example.backend.repo.CoinTransactionRepo coinTransactionRepo;

    @GetMapping
    public ResponseEntity<Integer> getBalance() {
        Child child = childService.getSelectedChild();
        return new ResponseEntity<>(child.getCoinBalance(), HttpStatus.OK);
    }

    @GetMapping("/history")
    public ResponseEntity<java.util.List<CoinTransactionDto>> getHistory() {
        Child child = childService.getSelectedChild();
        var dtos = coinTransactionRepo.findByChildIdOrderByCreatedAtDesc(child.getId())
                .stream().map(CoinTransactionDto::from).toList();
        return new ResponseEntity<>(dtos, HttpStatus.OK);
    }

    @PostMapping("/award")
    public ResponseEntity<?> award(@RequestParam CoinReason reason) {
        if (reason == CoinReason.MAZE_COIN_COLLECT) {
            return new ResponseEntity<>("Use /api/coins/maze-collect for this reason", HttpStatus.BAD_REQUEST);
        }
        Child child = childService.getSelectedChild();
        return new ResponseEntity<>(coinService.awardCoins(child, reason), HttpStatus.OK);
    }
}