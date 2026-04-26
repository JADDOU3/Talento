package org.example.backend.repo.event;

import org.example.backend.model.event.HelpEvent;
import org.example.backend.util.enums.HelpLevel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HelpEventRepo extends JpaRepository<HelpEvent, Integer> {
    List<HelpEvent> findByChildId(int childId);
    List<HelpEvent> findBySessionId(int sessionId);
    List<HelpEvent> findByHelpLevel(HelpLevel helpLevel);
    List<HelpEvent> findByChildIdAndHelpLevel(int childId, HelpLevel helpLevel);
}