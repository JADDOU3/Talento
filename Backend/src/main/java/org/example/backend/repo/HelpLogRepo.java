package org.example.backend.repo;

import org.example.backend.model.HelpLog;
import org.example.backend.util.enums.HelpLevel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HelpLogRepo extends JpaRepository<HelpLog, Integer> {
    List<HelpLog> findByActivitySessionId(int activitySessionId);
    List<HelpLog> findByActivitySessionIdAndHelpLevel(int activitySessionId, HelpLevel helpLevel);
}
