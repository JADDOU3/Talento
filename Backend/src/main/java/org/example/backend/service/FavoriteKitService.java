package org.example.backend.service;

import org.example.backend.Dto.Favorite.FavoriteKitDto;
import org.example.backend.model.FavoriteKit;
import org.example.backend.model.Kit;
import org.example.backend.model.Parent;
import org.example.backend.repo.FavoriteKitRepo;
import org.example.backend.repo.KitRepo;
import org.example.backend.service.community.S3Service;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class FavoriteKitService {

    @Autowired
    private FavoriteKitRepo favoriteKitRepo;
    @Autowired
    private KitRepo kitRepo;
    @Autowired
    private S3Service s3Service;
    public FavoriteKitDto addFavorite(int kitId) {
        Parent parent=SecurityUtils.getCurrentUser();

        Kit kit=kitRepo.findById(kitId).orElse(null);
        if (kit==null) return null;

        List<FavoriteKit> existing=favoriteKitRepo.findByParentIdAndKitId(parent.getId(), kitId);
        if (!existing.isEmpty()) return null;

        FavoriteKit favorite=new FavoriteKit();
        favorite.setParent(parent);
        favorite.setKit(kit);
        favoriteKitRepo.save(favorite);

        return toDto(favorite);
    }

    public boolean removeFavorite(int kitId) {
        Parent parent=SecurityUtils.getCurrentUser();

        List<FavoriteKit> existing=favoriteKitRepo.findByParentIdAndKitId(parent.getId(), kitId);
        if (existing.isEmpty()) return false;

        favoriteKitRepo.delete(existing.get(0));
        return true;
    }

    public List<FavoriteKitDto> getFavorites() {
        int parentId=SecurityUtils.getCurrentUser().getId();
        List<FavoriteKit> favorites=favoriteKitRepo.findByParentId(parentId);
        List<FavoriteKitDto> dtos=new ArrayList<>();
        for (FavoriteKit favorite : favorites) {
            dtos.add(toDto(favorite));
        }
        return dtos;
    }

    public boolean isFavorited(int kitId) {
        int parentId=SecurityUtils.getCurrentUser().getId();
        List<FavoriteKit> existing=favoriteKitRepo.findByParentIdAndKitId(parentId, kitId);
        return !existing.isEmpty();
    }

    private FavoriteKitDto toDto(FavoriteKit favorite) {
        FavoriteKitDto dto = new FavoriteKitDto();
        dto.setId(favorite.getId());
        dto.setKitId(favorite.getKit().getId());
        dto.setKitName(favorite.getKit().getName());
        dto.setKitPrice(favorite.getKit().getPrice());
        dto.setKitRating(favorite.getKit().getRating());
        dto.setCreatedAt(favorite.getCreatedAt());

        String imageKey = favorite.getKit().getImageKey();
        dto.setKitImageURL(
                imageKey != null && !imageKey.isEmpty()
                        ? s3Service.generatePresignedUrl(imageKey)
                        : null
        );
        return dto;
    }
}