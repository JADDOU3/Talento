package org.example.backend.controller;


import org.example.backend.Dto.kit.CreateKitDto;
import org.example.backend.Dto.kit.UpdateKitDto;
import org.example.backend.model.Kit;
import org.example.backend.service.KitService;
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

}
