package org.example.backend.service;

import org.example.backend.Dto.SessionStartDto;
import org.example.backend.Dto.session.SessionResponseDto;
import org.example.backend.model.Session;
import org.example.backend.repo.ChildKitRepo;
import org.example.backend.repo.SessionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SessionService {

    @Autowired
    private SessionRepo sessionRepo;
    @Autowired
    private ChildService childService;
    @Autowired
    private KitService kitService;
    @Autowired
    private ChildKitRepo childKitRepo;

    @Transactional
    public SessionResponseDto startSession(SessionStartDto sessionStartDto) {
        Session session = new Session();
        session.setStartedAt(LocalDateTime.now());
        session.setChild(childService.getChildById(sessionStartDto.getChildId()));
        session.setKit(kitService.getKitById(sessionStartDto.getKitId()));

        boolean ownsKit = childKitRepo.existsByChildAndKit(session.getChild(), session.getKit());
        if (!ownsKit) return null;

        return SessionResponseDto.from(sessionRepo.save(session));
    }

    public Session getSessionById(int id) {
        return sessionRepo.findById(id).orElse(null);
    }

    @Transactional(readOnly = true)
    public SessionResponseDto getSessionResponseById(int id) {
        return SessionResponseDto.from(getSessionById(id));
    }

    @Transactional(readOnly = true)
    public List<SessionResponseDto> getAllSessionsByChild(int childId) {
        return sessionRepo.findByChildId(childId).stream().map(SessionResponseDto::from).toList();
    }

    public void deleteSession(int id) {
        Session session = getSessionById(id);
        if (session != null) {
            sessionRepo.delete(session);
        }
    }

    @Transactional
    public SessionResponseDto endSession(int id) {
        Session session = getSessionById(id);
        if (session == null) return null;
        session.setEndedAt(LocalDateTime.now());
        return SessionResponseDto.from(sessionRepo.save(session));
    }

    @Transactional(readOnly = true)
    public List<SessionResponseDto> getAllSessionsByKit(int kitId) {
        return sessionRepo.findByKitId(kitId).stream().map(SessionResponseDto::from).toList();
    }
}
