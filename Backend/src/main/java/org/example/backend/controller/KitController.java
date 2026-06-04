package org.example.backend.controller;

import org.example.backend.Dto.kit.AddToChildCollectionDto;
import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.KitResponseDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.ChildKit;
import org.example.backend.service.ChildService;
import org.example.backend.service.KitService;
import org.example.backend.util.PaginationUtil;
import org.example.backend.util.enums.Type;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/api/kits")
@RestController
public class KitController {

    @Autowired
    private KitService kitService;

    @Autowired
    private ChildService childService;

    @PostMapping("/")
    public ResponseEntity<KitResponseDto> addKit(@RequestBody CreateKitDto createKitDto) {
        return new ResponseEntity<>(KitResponseDto.from(kitService.createKit(createKitDto)), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<Page<KitResponseDto>> getAllKits(
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return new ResponseEntity<>(kitService.getAllKits(pageable).map(KitResponseDto::from), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<KitResponseDto> getKitByID(@PathVariable int id) {
        var kit = kitService.getKitById(id);
        if (kit != null)
            return new ResponseEntity<>(KitResponseDto.from(kit), HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/")
    public ResponseEntity<KitResponseDto> updateKit(@RequestBody UpdateKitDto updateKitDto) {
        var kit = kitService.updateKit(updateKitDto);
        if (kit != null)
            return new ResponseEntity<>(KitResponseDto.from(kit), HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteKit(@PathVariable int id) {
        if (kitService.getKitById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(kitService.deleteKit(id), HttpStatus.OK);
    }

    @GetMapping("/child/{id}")
    public ResponseEntity<Page<ChildKit>> getKitsByChildId(@PathVariable int id, Pageable pageable) {
        if (childService.getChildById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(kitService.getKitsByChildId(id), pageable), HttpStatus.OK);
    }

    @PostMapping("/child/")
    public ResponseEntity<?> addToChildsCollection(@RequestBody AddToChildCollectionDto dto) {
        if (kitService.getKitById(dto.getKitId()) == null)
            return new ResponseEntity<>("Kit not found", HttpStatus.NOT_FOUND);
        if (childService.getChildById(dto.getChildId()) == null)
            return new ResponseEntity<>("Child not found", HttpStatus.NOT_FOUND);
        try {
            return new ResponseEntity<>(kitService.addToChildsCollection(dto), HttpStatus.CREATED);
        } catch (RuntimeException e) {
            return new ResponseEntity<>(e.getMessage(), HttpStatus.CONFLICT);
        }
    }

    @DeleteMapping("/child/{childId}/kit/{kitId}")
    public ResponseEntity<String> removeFromChildsCollection(
            @PathVariable int childId, @PathVariable int kitId) {
        return new ResponseEntity<>(kitService.removeFromChildsCollection(childId, kitId), HttpStatus.OK);
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<Page<KitResponseDto>> getKitsByType(@PathVariable Type type, Pageable pageable) {
        var dtos = kitService.getKitsByType(type).stream().map(KitResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<KitResponseDto>> getKitsByMindset(@PathVariable int mindsetId, Pageable pageable) {
        var dtos = kitService.getKitsByMindset(mindsetId).stream().map(KitResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<KitResponseDto>> searchKits(@RequestParam String keyword, Pageable pageable) {
        var dtos = kitService.searchKitsByName(keyword).stream().map(KitResponseDto::from).toList();
        return new ResponseEntity<>(PaginationUtil.paginate(dtos, pageable), HttpStatus.OK);
    }
}
