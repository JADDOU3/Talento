package org.example.backend.controller.mindset;

import org.example.backend.Dto.mindset.CreateMindsetDto;
import org.example.backend.Dto.mindset.UpdateMindsetDto;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.service.mindset.MindsetService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mindsets")
public class MindsetController {

    @Autowired
    private MindsetService mindsetService;

    @PostMapping
    public ResponseEntity<Mindset> createMindset(@RequestBody CreateMindsetDto dto) {
        return ResponseEntity.ok(mindsetService.createMindset(dto));
    }

    @GetMapping
    public ResponseEntity<Page<Mindset>> getAllMindsets(Pageable pageable) {
        return ResponseEntity.ok(PaginationUtil.paginate(mindsetService.getAllMindsets(), pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Mindset> getMindsetById(@PathVariable int id) {
        Mindset mindset = mindsetService.getMindsetById(id);
        return mindset != null ? ResponseEntity.ok(mindset) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<Mindset> updateMindset(@PathVariable int id, @RequestBody UpdateMindsetDto dto) {
        Mindset mindset = mindsetService.updateMindset(id, dto);
        return mindset != null ? ResponseEntity.ok(mindset) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMindset(@PathVariable int id) {
        mindsetService.deleteMindset(id);
        return ResponseEntity.noContent().build();
    }
}
