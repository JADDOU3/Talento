package org.example.backend.repo;

import org.example.backend.model.ActivitySession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ActivitySessionRepo extends JpaRepository<ActivitySession, Integer> {
    List<ActivitySession> findBySessionId(int sessionId);
}
