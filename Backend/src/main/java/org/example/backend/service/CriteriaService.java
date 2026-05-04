package org.example.backend.service;

import org.example.backend.model.Criteria;
import org.example.backend.repo.CriteriaRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CriteriaService {

    @Autowired
    private CriteriaRepo criteriaRepo;

    public Criteria createCriteria(Criteria criteria) {
        return criteriaRepo.save(criteria);
    }

    public List<Criteria> getCriteriaByMindset(int mindsetId) {
        return criteriaRepo.findByMindsetId(mindsetId);
    }

    public Criteria getCriteriaById(int id) {
        return criteriaRepo.findById(id).orElse(null);
    }

    public void deleteCriteria(int id) {
        criteriaRepo.deleteById(id);
    }
}
