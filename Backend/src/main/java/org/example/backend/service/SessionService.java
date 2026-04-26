package org.example.backend.service;

import org.example.backend.Dto.SessionStartDto;
import org.example.backend.model.Session;
import org.example.backend.repo.ChildKitRepo;
import org.example.backend.repo.SessionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

    public Session startSession(SessionStartDto sessionStartDto) {
        Session session = new Session();
        session.setStartedAt(LocalDateTime.now());
        session.setChild(childService.getChildById(sessionStartDto.getChildId()));
        session.setKit(kitService.getKitById(sessionStartDto.getKitId()));

        boolean ownsKit = childKitRepo.existsByChildAndKit(session.getChild(), session.getKit());
        if (!ownsKit)
            return null;

        return sessionRepo.save(session);
    }

    public Session getSessionById(int id) {
        return sessionRepo.findById(id).orElse(null);
    }

    public List<Session> getAllSessionsByChild(int childId) {
        return sessionRepo.findByChildId(childId);
    }

    public void deleteSession(int id) {
        Session session = getSessionById(id);
        sessionRepo.delete(session);
    }

    public Session endSession(int id) {
        Session session = getSessionById(id);
        session.setEndedAt(LocalDateTime.now());
        return sessionRepo.save(session);
    }

    public List<Session> getAllSessionsByKit(int kitId) {
        return sessionRepo.findByKitId(kitId);
    }
}