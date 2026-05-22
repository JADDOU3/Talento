package org.example.backend.repo;

import org.example.backend.model.AIReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AIReportRepo extends JpaRepository<AIReport, Integer> {
    List<AIReport> findByChildId(int childId);
    AIReport findTopByChildIdOrderByGeneratedAtDesc(int childId);
}
