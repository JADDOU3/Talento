package org.example.backend.service.mindset;

import org.example.backend.Dto.criteria.CreateCriteriaDto;
import org.example.backend.Dto.criteria.UpdateCriteriaDto;
import org.example.backend.model.mindset.Criteria;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.repo.mindset.CriteriaRepo;
import org.example.backend.repo.mindset.MindsetRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CriteriaService {

    @Autowired
    private CriteriaRepo criteriaRepo;

    @Autowired
    private MindsetRepo mindsetRepo;

    public Criteria createCriteria(CreateCriteriaDto dto) {
        Mindset mindset = mindsetRepo.findById(dto.getMindsetId()).orElse(null);
        if (mindset == null) return null;

        Criteria criteria = new Criteria();
        criteria.setName(dto.getName());
        criteria.setWeight(dto.getWeight());
        criteria.setMindset(mindset);
        return criteriaRepo.save(criteria);
    }

    public List<Criteria> getAllCriteria() {
        return criteriaRepo.findAll();
    }

    public List<Criteria> getCriteriaByMindset(int mindsetId) {
        return criteriaRepo.findByMindsetId(mindsetId);
    }

    public Criteria getCriteriaById(int id) {
        return criteriaRepo.findById(id).orElse(null);
    }

    public Criteria updateCriteria(int id, UpdateCriteriaDto dto) {
        Criteria criteria = getCriteriaById(id);
        if (criteria != null) {
            criteria.setName(dto.getName());
            criteria.setWeight(dto.getWeight());
            return criteriaRepo.save(criteria);
        }
        return null;
    }

    public void deleteCriteria(int id) {
        criteriaRepo.deleteById(id);
    }
}
