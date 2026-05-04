package org.example.backend.controller;

import org.example.backend.Dto.criteria.CreateCriteriaDto;
import org.example.backend.Dto.criteria.UpdateCriteriaDto;
import org.example.backend.model.Criteria;
import org.example.backend.service.CriteriaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/criteria")
public class CriteriaController {

    @Autowired
    private CriteriaService criteriaService;

    @PostMapping
    public ResponseEntity<Criteria> createCriteria(@RequestBody CreateCriteriaDto dto) {
        Criteria criteria = criteriaService.createCriteria(dto);
        return criteria != null ? ResponseEntity.ok(criteria) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<List<Criteria>> getAllCriteria() {
        return ResponseEntity.ok(criteriaService.getAllCriteria());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Criteria> getCriteriaById(@PathVariable int id) {
        Criteria criteria = criteriaService.getCriteriaById(id);
        return criteria != null ? ResponseEntity.ok(criteria) : ResponseEntity.notFound().build();
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<List<Criteria>> getCriteriaByMindset(@PathVariable int mindsetId) {
        return ResponseEntity.ok(criteriaService.getCriteriaByMindset(mindsetId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Criteria> updateCriteria(@PathVariable int id, @RequestBody UpdateCriteriaDto dto) {
        Criteria criteria = criteriaService.updateCriteria(id, dto);
        return criteria != null ? ResponseEntity.ok(criteria) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCriteria(@PathVariable int id) {
        criteriaService.deleteCriteria(id);
        return ResponseEntity.noContent().build();
    }
}
