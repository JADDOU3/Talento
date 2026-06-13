package org.example.backend.service.activity;

import org.example.backend.Dto.activitySession.ActivitySessionResponseDto;
import org.example.backend.Dto.activitySession.StartActivitySessionDto;
import org.example.backend.Dto.activitySession.UpdateActivitySessionDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.Session;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.SessionRepo;
import org.example.backend.service.SessionService;
import org.example.backend.service.community.S3Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ActivitySessionService {

    @Autowired
    private ActivitySessionRepo activitySessionRepo;
    @Autowired
    private SessionService sessionService;
    @Autowired
    private ActivityService activityService;
    @Autowired
    private SessionRepo sessionRepo;
    @Autowired
    private ActivityRepo activityRepo;
    @Autowired
    private S3Service s3Service;

    @Transactional
    public ActivitySessionResponseDto createActivitySession(StartActivitySessionDto startActivitySessionDto) {
        Session session = sessionRepo.findById(startActivitySessionDto.getSessionId())
                .orElseThrow(() -> new RuntimeException("Session not found"));
        Activity activity = activityRepo.findById(startActivitySessionDto.getActivityId())
                .orElseThrow(() -> new RuntimeException("Activity not found"));

        ActivitySession activitySession = new ActivitySession();
        activitySession.setOrderIndex(startActivitySessionDto.getOrderIndex());
        activitySession.setStartedAt(LocalDateTime.now());
        activitySession.setActivity(activity);
        activitySession.setSession(session);

        return toResponseDto(activitySessionRepo.save(activitySession));
    }

    @Transactional(readOnly = true)
    public ActivitySessionResponseDto getActivitySessionById(int id) {
        return activitySessionRepo.findById(id).map(this::toResponseDto).orElse(null);
    }

    @Transactional(readOnly = true)
    public List<ActivitySessionResponseDto> getAllActivitySessionsBySession(int sessionId) {
        return activitySessionRepo.findBySessionId(sessionId).stream().map(this::toResponseDto).toList();
    }

    @Transactional
    public ActivitySessionResponseDto updateActivitySession(UpdateActivitySessionDto updateActivitySessionDto) {
        ActivitySession activitySession = activitySessionRepo.findById(updateActivitySessionDto.getId()).orElse(null);
        if (activitySession == null) return null;

        if (updateActivitySessionDto.getOrderIndex() != null) {
            activitySession.setOrderIndex(updateActivitySessionDto.getOrderIndex());
        }
        if (updateActivitySessionDto.getStartedAt() != null) {
            activitySession.setStartedAt(updateActivitySessionDto.getStartedAt());
        }
        if (updateActivitySessionDto.getEndedAt() != null) {
            activitySession.setEndedAt(updateActivitySessionDto.getEndedAt());
        }

        activitySession.setActivity(activityService.getRawActivityById(updateActivitySessionDto.getActivityId()));
        activitySession.setSession(sessionService.getSessionById(updateActivitySessionDto.getSessionId()));

        return toResponseDto(activitySessionRepo.save(activitySession));
    }

    public void deleteActivitySession(int id) {
        ActivitySession activitySession = activitySessionRepo.findById(id).orElse(null);
        if (activitySession != null) {
            activitySessionRepo.delete(activitySession);
        }
    }

    @Transactional(readOnly = true)
    public List<ActivitySessionResponseDto> getAllActivitySessions() {
        return activitySessionRepo.findAll().stream().map(this::toResponseDto).toList();
    }

    @Transactional
    public ActivitySessionResponseDto endActivitySession(int id) {
        ActivitySession activitySession = activitySessionRepo.findById(id).orElse(null);
        if (activitySession == null) return null;
        activitySession.setEndedAt(LocalDateTime.now());
        return toResponseDto(activitySessionRepo.save(activitySession));
    }

    private ActivitySessionResponseDto toResponseDto(ActivitySession activitySession) {
        String coverUrl = null;
        if (activitySession.getActivity() != null
                && activitySession.getActivity().getCoverImageKey() != null
                && !activitySession.getActivity().getCoverImageKey().isEmpty()) {
            coverUrl = s3Service.generatePresignedUrl(activitySession.getActivity().getCoverImageKey());
        }
        return ActivitySessionResponseDto.from(activitySession, coverUrl);
    }
}
