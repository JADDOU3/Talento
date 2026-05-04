package org.example.backend.service;

import org.example.backend.model.ChildMindsetScore;
import org.example.backend.repo.ChildMindsetScoreRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChildMindsetScoreService {

    @Autowired
    private ChildMindsetScoreRepo childMindsetScoreRepo;

    public ChildMindsetScore saveScore(ChildMindsetScore score) {
        score.setLastUpdated(LocalDateTime.now());
        return childMindsetScoreRepo.save(score);
    }

    public List<ChildMindsetScore> getScoresByChild(int childId) {
        return childMindsetScoreRepo.findByChildId(childId);
    }

    public List<ChildMindsetScore> getScoresByMindset(int mindsetId) {
        return childMindsetScoreRepo.findByMindsetId(mindsetId);
    }
}
