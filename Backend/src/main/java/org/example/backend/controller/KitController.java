package org.example.backend.controller;


import org.example.backend.Dto.KitDto;
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

    @PostMapping("")
    public ResponseEntity<Kit> addKit(@RequestBody KitDto d){

        return new ResponseEntity<>(kitService.createKit(d), HttpStatus.CREATED);
    }

    @GetMapping("")
    public ResponseEntity<List<Kit>> getAllKits(){
        return new ResponseEntity<>(kitService.getAllKits(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Kit> getKitByID(@PathVariable int id){
        Kit x = kitService.getKitById(id);
        if(x != null)
            return new ResponseEntity<>(x , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Kit> updateKit(@PathVariable int id, @RequestBody KitDto x){
        Kit y = kitService.updateKit(id,x);
        if(y != null)
            return new ResponseEntity<>(y , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public void deleteKit(@PathVariable int id){
        kitService.deleteKit(id);
    }

}
