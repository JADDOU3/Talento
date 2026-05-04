package org.example.backend.controller.mindset;

import org.example.backend.Dto.mindset.CreateMindsetDto;
import org.example.backend.Dto.mindset.UpdateMindsetDto;
import org.example.backend.model.mindset.Mindset;
import org.example.backend.service.mindset.MindsetService;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<List<Mindset>> getAllMindsets() {
        return ResponseEntity.ok(mindsetService.getAllMindsets());
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
