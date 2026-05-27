package org.example.backend.controller.mindset;

import org.example.backend.Dto.criteria.CreateCriteriaDto;
import org.example.backend.Dto.criteria.UpdateCriteriaDto;
import org.example.backend.model.mindset.Criteria;
import org.example.backend.service.mindset.CriteriaService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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
    public ResponseEntity<Page<Criteria>> getAllCriteria(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(criteriaService.getAllCriteria(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Criteria> getCriteriaById(@PathVariable int id) {
        Criteria criteria = criteriaService.getCriteriaById(id);
        return criteria != null ? ResponseEntity.ok(criteria) : ResponseEntity.notFound().build();
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<Criteria>> getCriteriaByMindset(@PathVariable int mindsetId, Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(criteriaService.getCriteriaByMindset(mindsetId), pageable));
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
