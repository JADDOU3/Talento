package org.example.backend.controller;

import org.example.backend.Dto.kit.AddToChildCollectionDto;
import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.Child;
import org.example.backend.model.ChildKit;
import org.example.backend.model.Kit;
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

import java.util.List;

@RequestMapping("/api/kits")
@RestController
public class KitController {

    @Autowired
    private KitService kitService;

    @Autowired
    private ChildService childService;

    @PostMapping("/")
    public ResponseEntity<Kit> addKit(@RequestBody CreateKitDto createKitDto) {
        return new ResponseEntity<>(kitService.createKit(createKitDto), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<Page<Kit>> getAllKits(
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return new ResponseEntity<>(kitService.getAllKits(pageable), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Kit> getKitByID(@PathVariable int id) {
        Kit kit = kitService.getKitById(id);
        if (kit != null)
            return new ResponseEntity<>(kit, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/")
    public ResponseEntity<Kit> updateKit(@RequestBody UpdateKitDto updateKitDto) {
        Kit kit = kitService.updateKit(updateKitDto);
        if (kit != null)
            return new ResponseEntity<>(kit, HttpStatus.OK);
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
        Child child = childService.getChildById(id);
        if (child == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(PaginationUtil.paginate(kitService.getKitsByChildId(id), pageable), HttpStatus.OK);
    }

    @PostMapping("/child/")
    public ResponseEntity<?> addToChildsCollection(@RequestBody AddToChildCollectionDto dto) {
        Kit kit = kitService.getKitById(dto.getKitId());
        if (kit == null)
            return new ResponseEntity<>("Kit not found", HttpStatus.NOT_FOUND);
        Child child = childService.getChildById(dto.getChildId());
        if (child == null)
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
    public ResponseEntity<Page<Kit>> getKitsByType(@PathVariable Type type, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(kitService.getKitsByType(type), pageable), HttpStatus.OK);
    }

    @GetMapping("/mindset/{mindsetId}")
    public ResponseEntity<Page<Kit>> getKitsByMindset(@PathVariable int mindsetId, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(kitService.getKitsByMindset(mindsetId), pageable), HttpStatus.OK);
    }

    @GetMapping("/search")
    public ResponseEntity<Page<Kit>> searchKits(@RequestParam String keyword, Pageable pageable) {
        return new ResponseEntity<>(PaginationUtil.paginate(kitService.searchKitsByName(keyword), pageable), HttpStatus.OK);
    }
}