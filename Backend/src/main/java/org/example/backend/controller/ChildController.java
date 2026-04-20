package org.example.backend.controller;

import org.example.backend.Dto.ChildUpdateDto;
import org.example.backend.Dto.CreateChildDto;
import org.example.backend.model.Child;
import org.example.backend.service.ChildService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/children")
public class ChildController {
    @Autowired
    private ChildService childService;

    @GetMapping("/{id}")
    public ResponseEntity<Child> getChildbyID(@PathVariable int id){
        Child x = childService.getChildById(id);
        if(x != null)
            return new ResponseEntity<>(x , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @GetMapping
    public ResponseEntity<List<Child>> getChildrenByCurrentUser(){
        List<Child> children = childService.getAllChildrenByUser(SecurityUtils.getCurrentUser().getId());
        if(children != null)
            return new ResponseEntity<>(children , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("/")
    public ResponseEntity<Child> addChild(@RequestBody CreateChildDto childDto){
        return new ResponseEntity<>(childService.createChild(childDto), HttpStatus.CREATED);
    }
    @PutMapping("/")
    public ResponseEntity<Child> updateChild(@RequestBody ChildUpdateDto childUpdateDto){
        Child child = childService.updateChild(childUpdateDto);
        if(child != null)
            return new ResponseEntity<>(child , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public String deleteChild(@PathVariable int id){
        return childService.deleteChild(id);
    }

    @GetMapping("/selected")
    public ResponseEntity<Child> getSelectedChild(){
        Child child = childService.getSelectedChild();
        if(child != null)
            return new ResponseEntity<>(child , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/selected/{id}")
    public Child selectChild(@PathVariable int id){
        return childService.selectChild(id);
    }

}
