package org.example.backend.service;

import org.example.backend.Dto.SessionDto;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.model.Session;
import org.example.backend.repo.SessionRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SessionService {

    @Autowired
    private SessionRepo sessionRepo;

    public Session createSession(SessionDto d) {
        Session session = new Session();
        Child child = new Child();
        Kit kit = new Kit();

        session.setStartedAt(d.getStartedAt());
        session.setEndedAt(d.getEndedAt());

        child.setId(d.getChildId());
        session.setChild(child);

        kit.setId(d.getKitId());
        session.setKit(kit);

        return sessionRepo.save(session);
    }

    public Session getSessionById(int id) {
        return sessionRepo.findById(id).orElse(null);
    }

    public List<Session> getAllSessionsByChild(int childId) {
        return sessionRepo.findByChildId(childId);
    }

    public Session updateSession(int id, SessionDto d) {
        Session oldSession = getSessionById(id);

        if (oldSession == null)
            return null;

        oldSession.setStartedAt(d.getStartedAt());
        oldSession.setEndedAt(d.getEndedAt());

        return sessionRepo.save(oldSession);
    }

    public void deleteSession(int id) {
        Session session = getSessionById(id);
        sessionRepo.delete(session);
    }

    public Session endSession(int id) {
        Session session = getSessionById(id);

        if (session == null)
            return null;

        session.setEndedAt(LocalDateTime.now());
        return sessionRepo.save(session);
    }
}