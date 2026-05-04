package org.example.backend.repo.mindset;

import org.example.backend.model.mindset.ChildMindsetScore;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChildMindsetScoreRepo extends JpaRepository<ChildMindsetScore, Integer> {
    List<ChildMindsetScore> findByChildId(int childId);
    List<ChildMindsetScore> findByMindsetId(int mindsetId);
}
