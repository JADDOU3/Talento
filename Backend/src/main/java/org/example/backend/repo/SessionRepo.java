package org.example.backend.repo;

import org.example.backend.model.Session;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface SessionRepo extends JpaRepository<Session, Integer> {
    List<Session> findByChildId(int childId);

    List<Session> findByKitId(int kitId);
}
