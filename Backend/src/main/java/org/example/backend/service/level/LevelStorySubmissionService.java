package org.example.backend.service.level;

import lombok.extern.slf4j.Slf4j;
import org.example.backend.Dto.level.LevelStorySubmissionResponseDto;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelStorySubmission;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.repo.level.LevelStorySubmissionRepo;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
public class LevelStorySubmissionService {

    private final LevelStorySubmissionRepo levelStorySubmissionRepo;
    private final ActivitySessionRepo activitySessionRepo;
    private final LevelRepo levelRepo;

    public LevelStorySubmissionService(LevelStorySubmissionRepo levelStorySubmissionRepo,
                                       ActivitySessionRepo activitySessionRepo,
                                       LevelRepo levelRepo) {
        this.levelStorySubmissionRepo = levelStorySubmissionRepo;
        this.activitySessionRepo = activitySessionRepo;
        this.levelRepo = levelRepo;
    }


    @Transactional
    public LevelStorySubmissionResponseDto saveSuccessfulSubmission(
            Integer activitySessionId,
            Integer levelId,
            String storyText,
            List<String> matchedKeywords) {

        if (activitySessionId == null || levelId == null) {
            log.debug("Story save skipped — activitySessionId={} levelId={}", activitySessionId, levelId);
            return null;
        }

        if (storyText == null || storyText.isBlank()) {
            log.warn("Story save skipped — blank storyText for activitySessionId={}", activitySessionId);
            return null;
        }

        ActivitySession activitySession = activitySessionRepo.findById(activitySessionId).orElse(null);
        if (activitySession == null) {
            log.warn("Story save failed — ActivitySession not found: id={}", activitySessionId);
            return null;
        }

        Level level = levelRepo.findById(levelId).orElse(null);
        if (level == null) {
            log.warn("Story save failed — Level not found: id={}", levelId);
            return null;
        }

        LevelStorySubmission submission = new LevelStorySubmission();
        submission.setActivitySession(activitySession);
        submission.setLevel(level);
        submission.setStoryText(storyText.trim());
        submission.setMatchedKeywords(joinKeywords(matchedKeywords));
        // submittedAt is set automatically by @PrePersist

        LevelStorySubmission saved = levelStorySubmissionRepo.save(submission);
        log.info("Saved story submission id={} — activitySessionId={} levelId={}",
                saved.getId(), activitySessionId, levelId);

        return toDto(saved);
    }


    @Transactional(readOnly = true)
    public List<LevelStorySubmissionResponseDto> getByActivitySession(int activitySessionId) {
        return levelStorySubmissionRepo
                .findByActivitySession_IdOrderBySubmittedAtDesc(activitySessionId)
                .stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LevelStorySubmissionResponseDto> getByActivity(int activityId) {
        return levelStorySubmissionRepo
                .findByActivityId(activityId)
                .stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LevelStorySubmissionResponseDto> getByChild(int childId) {
        return levelStorySubmissionRepo
                .findByChildId(childId)
                .stream().map(this::toDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<LevelStorySubmissionResponseDto> getByActivityAndChild(int activityId, int childId) {
        return levelStorySubmissionRepo
                .findByActivityIdAndChildId(activityId, childId)
                .stream().map(this::toDto).collect(Collectors.toList());
    }


    @Transactional(readOnly = true)
    public long countByActivity(int activityId) {
        return levelStorySubmissionRepo.countByActivityId(activityId);
    }

    @Transactional(readOnly = true)
    public long countByChild(int childId) {
        return levelStorySubmissionRepo.countByChildId(childId);
    }

    @Transactional(readOnly = true)
    public long countByActivityAndChild(int activityId, int childId) {
        return levelStorySubmissionRepo.countByActivityIdAndChildId(activityId, childId);
    }


    private String joinKeywords(List<String> keywords) {
        if (keywords == null || keywords.isEmpty()) return null;
        return keywords.stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(k -> !k.isEmpty())
                .distinct()
                .collect(Collectors.joining(","));
    }

    private List<String> splitKeywords(String joined) {
        if (joined == null || joined.isBlank()) return Collections.emptyList();
        return Arrays.stream(joined.split(","))
                .map(String::trim)
                .filter(k -> !k.isEmpty())
                .collect(Collectors.toList());
    }

    private LevelStorySubmissionResponseDto toDto(LevelStorySubmission s) {
        return new LevelStorySubmissionResponseDto(
                s.getId(),
                s.getStoryText(),
                splitKeywords(s.getMatchedKeywords()),
                s.getSubmittedAt(),
                s.getLevel().getId(),
                s.getActivitySession().getId(),
                s.getActivitySession().getActivity().getId(),
                s.getActivitySession().getSession().getChild().getId()
        );
    }
}