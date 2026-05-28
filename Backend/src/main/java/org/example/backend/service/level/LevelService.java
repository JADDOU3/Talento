package org.example.backend.service.level;

import org.example.backend.Dto.level.CreateLevelDto;
import org.example.backend.Dto.level.LevelImageDto;
import org.example.backend.Dto.level.LevelImageResponseDto;
import org.example.backend.Dto.level.LevelResponseDto;
import org.example.backend.Dto.level.UpdateLevelDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelImage;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.service.community.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Service
public class LevelService {

    @Autowired
    private LevelRepo levelRepo;
    @Autowired
    private ActivityRepo activityRepo;
    @Autowired
    private S3Service s3Service;

    public LevelResponseDto createLevel(CreateLevelDto dto) {
        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);
        if (activity == null) return null;

        Level level = new Level();
        level.setLevelNumber(dto.getLevelNumber());
        level.setDifficulty(dto.getDifficulty());
        level.setDescription(dto.getDescription());
        level.setImages(mapImages(dto.getImages(), level));
        level.setActivity(activity);
        return toResponseDto(levelRepo.save(level));
    }

    public List<LevelResponseDto> getAll() {
        return levelRepo.findAll().stream().map(this::toResponseDto).toList();
    }

    public LevelResponseDto getLevelById(int id) {
        return levelRepo.findById(id).map(this::toResponseDto).orElse(null);
    }

    public List<LevelResponseDto> getLevelsByActivity(int activityId) {
        return levelRepo.findByActivityIdOrderByLevelNumber(activityId)
                .stream().map(this::toResponseDto).toList();
    }

    public LevelResponseDto updateLevel(int id, UpdateLevelDto dto) {
        Level level = levelRepo.findById(id).orElse(null);
        if (level == null) return null;
        level.setLevelNumber(dto.getLevelNumber());
        level.setDifficulty(dto.getDifficulty());
        level.setDescription(dto.getDescription());
        if (dto.getImages() != null) {
            level.setImages(mapImages(dto.getImages(), level));
        }
        return toResponseDto(levelRepo.save(level));
    }

    public void deleteLevel(int id) {
        levelRepo.deleteById(id);
    }

    private List<LevelImage> mapImages(List<LevelImageDto> images, Level level) {
        if (images == null) return null;
        return images.stream().map(dto -> {
            LevelImage image = new LevelImage();
            image.setS3Key(dto.getS3Key());
            image.setRole(dto.getRole());
            image.setLabel(dto.getLabel());
            image.setDescription(dto.getDescription());
            image.setSortOrder(dto.getSortOrder());
            image.setMeta(dto.getMeta());
            image.setLevel(level);
            return image;
        }).toList();
    }

    private LevelResponseDto toResponseDto(Level level) {
        List<LevelImageResponseDto> imageDtos = (level.getImages() != null)
                ? level.getImages().stream()
                  .map(img -> new LevelImageResponseDto(
                          img,
                          s3Service.generatePresignedUrl(img.getS3Key())
                  )).toList()
                : Collections.emptyList();
        return new LevelResponseDto(level, imageDtos);
    }
}