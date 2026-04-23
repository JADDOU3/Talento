package org.example.backend.controller;


import org.example.backend.Dto.kit.AddToChildCollectionDto;
import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.Child;
import org.example.backend.model.Kit;
import org.example.backend.service.ChildService;
import org.example.backend.service.KitService;
import org.example.backend.util.enums.Mindset;
import org.example.backend.util.enums.Type;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<Kit> addKit(@RequestBody CreateKitDto createKitDto){
        return new ResponseEntity<>(kitService.createKit(createKitDto), HttpStatus.CREATED);
    }

    @GetMapping("/")
    public ResponseEntity<List<Kit>> getAllKits(){
        return new ResponseEntity<>(kitService.getAllKits(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Kit> getKitByID(@PathVariable int id){
        Kit kit = kitService.getKitById(id);
        if(kit != null)
            return new ResponseEntity<>(kit , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/")
    public ResponseEntity<Kit> updateKit(@RequestBody UpdateKitDto updateKitDto){
        Kit kit = kitService.updateKit(updateKitDto);
        if(kit != null)
            return new ResponseEntity<>(kit , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteKit(@PathVariable int id){
        if(kitService.getKitById(id) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(kitService.deleteKit(id) , HttpStatus.OK);
    }

    @GetMapping("/child/{id}")
    public ResponseEntity<List<Kit>> getKitsByChildId(@PathVariable int id){
        List<Kit> kits = kitService.getKitsByChildId(id);
        if(kits == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(kitService.getKitsByChildId(id), HttpStatus.OK);
    }

    @PostMapping("/child/")
    public ResponseEntity<Kit> addToChildsCollection(@RequestBody AddToChildCollectionDto addToChildCollectionDto){
        Kit kit = kitService.getKitById(addToChildCollectionDto.getKitId());
        if(kit == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        Child child = childService.getChildById(addToChildCollectionDto.getChildId());
        if (child == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        return new ResponseEntity<>(kitService.addToChildsCollection(addToChildCollectionDto), HttpStatus.OK);

    }

    @GetMapping("/type/{type}")
    public ResponseEntity<List<Kit>> getKitsByType(@PathVariable Type type) {
        return new ResponseEntity<>(kitService.getKitsByType(type), HttpStatus.OK);
    }

    @GetMapping("/mindset/{mindset}")
    public ResponseEntity<List<Kit>> getKitsByMindset(@PathVariable Mindset mindset) {
        return new ResponseEntity<>(kitService.getKitsByMindset(mindset), HttpStatus.OK);
    }

    @GetMapping("/search")
    public ResponseEntity<List<Kit>> searchKits(@RequestParam String keyword) {
        return new ResponseEntity<>(kitService.searchKitsByName(keyword), HttpStatus.OK);
    }

}
