package org.example.backend.service.roadmap;

import org.example.backend.Dto.roadmap.CreateRoadmapCardDto;
import org.example.backend.Dto.roadmap.RoadmapCardDto;
import org.example.backend.Dto.roadmap.RoadmapResponseDto;
import org.example.backend.model.Kit;
import org.example.backend.model.RoadmapCard;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivityProgress;
import org.example.backend.model.level.Level;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.RoadmapCardRepo;
import org.example.backend.repo.activity.ActivityProgressRepo;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.service.community.S3Service;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class RoadmapService {

    private final RoadmapCardRepo roadmapCardRepo;
    private final LevelRepo levelRepo;
    private final KitRepo kitRepo;
    private final ActivityRepo activityRepo;
    private final ActivityProgressRepo activityProgressRepo;
    private final S3Service s3Service;

    public RoadmapService(
            RoadmapCardRepo roadmapCardRepo,
            LevelRepo levelRepo,
            KitRepo kitRepo,
            ActivityRepo activityRepo,
            ActivityProgressRepo activityProgressRepo,
            S3Service s3Service
    ) {
        this.roadmapCardRepo = roadmapCardRepo;
        this.levelRepo = levelRepo;
        this.kitRepo = kitRepo;
        this.activityRepo = activityRepo;
        this.activityProgressRepo = activityProgressRepo;
        this.s3Service = s3Service;
    }

    // ─── READ ────────────────────────────────────────────────────────────────

    public RoadmapResponseDto getRoadmap(int kitId, int childId) {
        Kit kit = kitRepo.findById(kitId).orElse(null);
        if (kit == null) return null;

        List<RoadmapCard> cards = roadmapCardRepo.findByKitIdOrderBySortOrder(kitId);
        List<RoadmapCardDto> result = new ArrayList<>();
        boolean previousCompleted = true;

        for (RoadmapCard card : cards) {
            Activity activity = card.getActivity();

            // Resolve levels in this card's range
            List<Level> cardLevels;
            if (card.getLevelFrom() == null || card.getLevelTo() == null) {
                cardLevels = levelRepo.findByActivityIdOrderByLevelNumber(activity.getId());
            } else {
                cardLevels = levelRepo.findByActivityIdAndLevelNumberBetweenOrderByLevelNumber(
                        activity.getId(), card.getLevelFrom(), card.getLevelTo()
                );
            }
            int totalLevels = cardLevels.size();

            // Read child's progress for this activity
            Optional<ActivityProgress> progressOpt = activityProgressRepo
                    .findByChildIdAndActivityId(childId, activity.getId());

            int currentLevelNumber = card.getLevelFrom() != null ? card.getLevelFrom() : 1;
            int completedLevels = 0;
            boolean cardCompleted = false;

            if (progressOpt.isPresent()) {
                ActivityProgress progress = progressOpt.get();

                if (card.getLevelFrom() == null || card.getLevelTo() == null) {
                    // Full activity card — unchanged
                    currentLevelNumber = progress.getCurrentLevelNumber();
                    completedLevels = progress.getCompletedLevels();
                    cardCompleted = progress.isCompleted();
                } else {
                    // Range card
                    int highestCompleted = progress.getCompletedLevels();

                    completedLevels = (int) cardLevels.stream()
                            .filter(l -> l.getLevelNumber() <= highestCompleted)
                            .count();

                    cardCompleted = highestCompleted >= card.getLevelTo();

                    int rawCurrent = progress.getCurrentLevelNumber();
                    currentLevelNumber = Math.min(
                            Math.max(rawCurrent, card.getLevelFrom()),
                            card.getLevelTo()
                    );
                }
            }

            String status;
            if (cardCompleted) {
                status = "COMPLETED";
            } else if (previousCompleted) {
                status = "CURRENT";
            } else {
                status = "CURRENT"; // todo: change to "LOCKED" when done testing
            }

            String coverImageUrl = null;
            if (activity.getCoverImageKey() != null && !activity.getCoverImageKey().isEmpty()) {
                coverImageUrl = s3Service.generatePresignedUrl(activity.getCoverImageKey());
            }

            result.add(new RoadmapCardDto(
                    card.getId(),
                    activity.getId(),
                    activity.getName(),
                    activity.getCoverImageKey(),
                    coverImageUrl,
                    status,
                    currentLevelNumber,
                    totalLevels,
                    completedLevels,
                    card.getLevelFrom(),
                    card.getLevelTo()
            ));

            previousCompleted = "COMPLETED".equals(status);
        }

        String kitImageUrl = (kit.getImageKey() != null && !kit.getImageKey().isEmpty())
                ? s3Service.generatePresignedUrl(kit.getImageKey())
                : null;
        return new RoadmapResponseDto(kit.getId(), kit.getName(), kitImageUrl, result);
    }

    // ─── CREATE ──────────────────────────────────────────────────────────────

    public RoadmapCardDto create(CreateRoadmapCardDto dto) {
        Kit kit = kitRepo.findById(dto.getKitId()).orElse(null);
        if (kit == null) return null;

        Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);
        if (activity == null) return null;

        RoadmapCard card = new RoadmapCard();
        card.setKit(kit);
        card.setActivity(activity);
        card.setSortOrder(dto.getSortOrder());
        card.setLevelFrom(dto.getLevelFrom());
        card.setLevelTo(dto.getLevelTo());

        RoadmapCard saved = roadmapCardRepo.save(card);
        return toDto(saved, activity);
    }

    // ─── UPDATE ──────────────────────────────────────────────────────────────

    public RoadmapCardDto update(int id, CreateRoadmapCardDto dto) {
        RoadmapCard card = roadmapCardRepo.findById(id).orElse(null);
        if (card == null) return null;

        // Allow switching activity on a card
        if (dto.getActivityId() != 0) {
            Activity activity = activityRepo.findById(dto.getActivityId()).orElse(null);
            if (activity == null) return null;
            card.setActivity(activity);
        }

        if (dto.getKitId() != 0) {
            Kit kit = kitRepo.findById(dto.getKitId()).orElse(null);
            if (kit == null) return null;
            card.setKit(kit);
        }

        card.setSortOrder(dto.getSortOrder());
        card.setLevelFrom(dto.getLevelFrom());  // pass null to reset to "all levels"
        card.setLevelTo(dto.getLevelTo());

        RoadmapCard saved = roadmapCardRepo.save(card);
        return toDto(saved, saved.getActivity());
    }

    // ─── DELETE ──────────────────────────────────────────────────────────────

    public void delete(int id) {
        roadmapCardRepo.deleteById(id);
    }

    // ─── HELPER ──────────────────────────────────────────────────────────────

    private RoadmapCardDto toDto(RoadmapCard card, Activity activity) {
        String coverImageUrl = (activity.getCoverImageKey() != null
                && !activity.getCoverImageKey().isEmpty())
                ? s3Service.generatePresignedUrl(activity.getCoverImageKey())
                : null;

        return new RoadmapCardDto(
                card.getId(),
                activity.getId(),
                activity.getName(),
                activity.getCoverImageKey(),
                coverImageUrl,
                "NONE",
                card.getLevelFrom() != null ? card.getLevelFrom() : 1,
                levelRepo.countByActivityId(activity.getId()),
                0,
                card.getLevelFrom(),
                card.getLevelTo()
        );
    }
}