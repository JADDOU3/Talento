package org.example.backend.controller.mindset;

import org.example.backend.Dto.criteria.CreateCriteriaDto;
import org.example.backend.Dto.criteria.CriteriaResponseDto;
import org.example.backend.Dto.criteria.UpdateCriteriaDto;
import org.example.backend.service.mindset.CriteriaService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/criteria")
public class CriteriaController {

    @Autowired
    private CriteriaService criteriaService;

    @PostMapping
    public ResponseEntity<CriteriaResponseDto> createCriteria(@RequestBody CreateCriteriaDto dto) {
        var criteria = criteriaService.createCriteria(dto);
        return criteria != null ? ResponseEntity.ok(CriteriaResponseDto.from(criteria)) : ResponseEntity.badRequest().build();
    }

    @GetMapping
    public ResponseEntity<Page<CriteriaResponseDto>> getAllCriteria(Pageable pageable) {
        var dtos = criteriaService.getAllCriteria().stream().map(CriteriaResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<CriteriaResponseDto> getCriteriaById(@PathVariable int id) {
        var criteria = criteriaService.getCriteriaById(id);
        return criteria != null ? ResponseEntity.ok(CriteriaResponseDto.from(criteria)) : ResponseEntity.notFound().build();
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<CriteriaResponseDto>> getCriteriaByMindset(@PathVariable int mindsetId, Pageable pageable) {
        var dtos = criteriaService.getCriteriaByMindset(mindsetId).stream().map(CriteriaResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CriteriaResponseDto> updateCriteria(@PathVariable int id, @RequestBody UpdateCriteriaDto dto) {
        var criteria = criteriaService.updateCriteria(id, dto);
        return criteria != null ? ResponseEntity.ok(CriteriaResponseDto.from(criteria)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCriteria(@PathVariable int id) {
        criteriaService.deleteCriteria(id);
        return ResponseEntity.noContent().build();
    }
}
