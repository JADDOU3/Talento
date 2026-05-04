package org.example.backend.service.mindset;

import org.example.backend.Dto.score.CreateChildMindsetScoreDto;
import org.example.backend.Dto.score.UpdateChildMindsetScoreDto;
import org.example.backend.model.Child;
import org.example.backend.model.mindset.ChildMindsetScore;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.repo.mindset.ChildMindsetScoreRepo;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.mindset.MindsetRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChildMindsetScoreService {

    @Autowired
    private ChildMindsetScoreRepo childMindsetScoreRepo;

    @Autowired
    private ChildRepo childRepo;

    @Autowired
    private MindsetRepo mindsetRepo;

    public ChildMindsetScore createScore(CreateChildMindsetScoreDto dto) {
        Child child = childRepo.findById(dto.getChildId()).orElse(null);
        Mindset mindset = mindsetRepo.findById(dto.getMindsetId()).orElse(null);

        if (child == null || mindset == null) return null;

        ChildMindsetScore score = new ChildMindsetScore();
        score.setScore(dto.getScore());
        score.setLastUpdated(LocalDateTime.now());
        score.setChild(child);
        score.setMindset(mindset);
        return childMindsetScoreRepo.save(score);
    }

    public List<ChildMindsetScore> getAll() {
        return childMindsetScoreRepo.findAll();
    }

    public ChildMindsetScore getById(int id) {
        return childMindsetScoreRepo.findById(id).orElse(null);
    }

    public List<ChildMindsetScore> getScoresByChild(int childId) {
        return childMindsetScoreRepo.findByChildId(childId);
    }

    public List<ChildMindsetScore> getScoresByMindset(int mindsetId) {
        return childMindsetScoreRepo.findByMindsetId(mindsetId);
    }

    public ChildMindsetScore updateScore(int id, UpdateChildMindsetScoreDto dto) {
        ChildMindsetScore score = getById(id);
        if (score != null) {
            score.setScore(dto.getScore());
            score.setLastUpdated(LocalDateTime.now());
            return childMindsetScoreRepo.save(score);
        }
        return null;
    }

    public void deleteScore(int id) {
        childMindsetScoreRepo.deleteById(id);
    }
}
