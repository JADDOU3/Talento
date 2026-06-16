package org.example.backend.controller;

import org.example.backend.Dto.Favorite.AddFavoriteDto;
import org.example.backend.Dto.Favorite.FavoriteKitDto;
import org.example.backend.service.FavoriteKitService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorites")
public class FavoriteKitController {

    @Autowired
    private FavoriteKitService favoriteKitService;

    @PostMapping("/")
    public ResponseEntity<FavoriteKitDto> addFavorite(@RequestBody AddFavoriteDto dto) {
        FavoriteKitDto favorite=favoriteKitService.addFavorite(dto.getKitId());
        if (favorite!=null)
            return new ResponseEntity<>(favorite, HttpStatus.CREATED);
        return new ResponseEntity<>(HttpStatus.CONFLICT);
    }

    @DeleteMapping("/{kitId}")
    public ResponseEntity<Void> removeFavorite(@PathVariable int kitId) {
        boolean removed=favoriteKitService.removeFavorite(kitId);
        if (removed)
            return new ResponseEntity<>(HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @GetMapping("/")
    public ResponseEntity<List<FavoriteKitDto>> getFavorites() {
        return new ResponseEntity<>(favoriteKitService.getFavorites(), HttpStatus.OK);
    }

    @GetMapping("/{kitId}/check")
    public ResponseEntity<Boolean> isFavorited(@PathVariable int kitId) {
        return new ResponseEntity<>(favoriteKitService.isFavorited(kitId), HttpStatus.OK);
    }
}