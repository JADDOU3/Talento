package org.example.backend.service;

import org.example.backend.Dto.CreateHelpLogDto;
import org.example.backend.Dto.helpLog.HelpLogResponseDto;
import org.example.backend.model.activity.ActivitySession;
import org.example.backend.model.HelpLog;
import org.example.backend.repo.activity.ActivitySessionRepo;
import org.example.backend.repo.HelpLogRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class HelpLogService {

    @Autowired
    private HelpLogRepo helpRepo;

    @Autowired
    private ActivitySessionRepo activitySessionRepo;

    @Transactional
    public HelpLogResponseDto createHelpLog(CreateHelpLogDto createHelpLogDto) {
        ActivitySession activitySession = activitySessionRepo.findById(createHelpLogDto.getActivitySessionId())
                .orElseThrow(() -> new RuntimeException("ActivitySession not found"));

        HelpLog helpLog = new HelpLog();
        helpLog.setHelpLevel(createHelpLogDto.getHelpLevel());
        helpLog.setCreatedAt(LocalDateTime.now());
        helpLog.setActivitySession(activitySession);

        return HelpLogResponseDto.from(helpRepo.save(helpLog));
    }

    @Transactional(readOnly = true)
    public HelpLogResponseDto getHelpLogById(int id) {
        return helpRepo.findById(id).map(HelpLogResponseDto::from).orElse(null);
    }

    @Transactional(readOnly = true)
    public List<HelpLogResponseDto> getHelpLogsByActivitySession(int activitySessionId) {
        return helpRepo.findByActivitySessionId(activitySessionId).stream()
                .map(HelpLogResponseDto::from).toList();
    }

    public void deleteHelpLog(int id) {
        helpRepo.deleteById(id);
    }
}
