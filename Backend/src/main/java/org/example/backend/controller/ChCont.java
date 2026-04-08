package org.example.backend.controller;

import org.example.backend.model.Child;
import org.example.backend.service.ChSer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin
@RestController
@RequestMapping("/api/children")
public class ChCont {
    @Autowired
    private ChSer childser;

    @GetMapping("/{id}")
    public ResponseEntity<Child> getChildbyID(@PathVariable int id){
        Child x = childser.getChildById(id);
        if(x != null)
            return new ResponseEntity<>(x , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }


    @GetMapping("/parent/{parentId}")
    public ResponseEntity<List<Child>> getChildrenByParentID(@PathVariable int parentId){
        List<Child> x = childser.getAllChildrenByParent(parentId);
        if(x != null)
            return new ResponseEntity<>(x , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("")
    public ResponseEntity<Child> addChild(@RequestBody Child x){
        return new ResponseEntity<>(childser.createChild(x), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Child> updateChild(@PathVariable int id, @RequestBody Child x){
        Child y = childser.updateChild(id,x);
        if(y != null)
            return new ResponseEntity<>(y , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public void deleteChild(@PathVariable int id){
        childser.deleteChild(id);
    }




}
