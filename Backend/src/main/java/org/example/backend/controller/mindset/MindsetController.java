package org.example.backend.controller.mindset;

import org.example.backend.Dto.mindset.CreateMindsetDto;
import org.example.backend.Dto.mindset.MindsetResponseDto;
import org.example.backend.Dto.mindset.UpdateMindsetDto;
import org.example.backend.service.mindset.MindsetService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mindsets")
public class MindsetController {

    @Autowired
    private MindsetService mindsetService;

    @PostMapping
    public ResponseEntity<MindsetResponseDto> createMindset(@RequestBody CreateMindsetDto dto) {
        return ResponseEntity.ok(MindsetResponseDto.from(mindsetService.createMindset(dto)));
    }

    @GetMapping
    public ResponseEntity<Page<MindsetResponseDto>> getAllMindsets(Pageable pageable) {
        var dtos = mindsetService.getAllMindsets().stream().map(MindsetResponseDto::from).toList();
        return ResponseEntity.ok(PaginationUtil.paginate(dtos, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<MindsetResponseDto> getMindsetById(@PathVariable int id) {
        var mindset = mindsetService.getMindsetById(id);
        return mindset != null ? ResponseEntity.ok(MindsetResponseDto.from(mindset)) : ResponseEntity.notFound().build();
    }

    @PutMapping("/{id}")
    public ResponseEntity<MindsetResponseDto> updateMindset(@PathVariable int id, @RequestBody UpdateMindsetDto dto) {
        var mindset = mindsetService.updateMindset(id, dto);
        return mindset != null ? ResponseEntity.ok(MindsetResponseDto.from(mindset)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMindset(@PathVariable int id) {
        mindsetService.deleteMindset(id);
        return ResponseEntity.noContent().build();
    }
}
