<<<<<<< HEAD
package org.example.backend.controller;

import org.example.backend.model.Child;
import org.example.backend.service.ChildService;
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


    @GetMapping("/parent/{userId}")
    public ResponseEntity<List<Child>> getChildrenByUserid(@PathVariable int userId){
        List<Child> x = childService.getAllChildrenByUser(userId);
        if(x != null)//CHECK DOESN'T WORK FOR NOW, user will never be null
            return new ResponseEntity<>(x , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("")
    public ResponseEntity<Child> addChild(@RequestBody Child x){
        return new ResponseEntity<>(childService.createChild(x), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Child> updateChild(@PathVariable int id, @RequestBody Child x){
        Child y = childService.updateChild(id,x);
        if(y != null)
            return new ResponseEntity<>(y , HttpStatus.OK);
        else
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public void deleteChild(@PathVariable int id){
        childService.deleteChild(id);
    }




}
=======
package org.example.backend.controller;

import org.example.backend.Dto.child.ChildUpdateDto;
import org.example.backend.Dto.child.CreateChildDto;
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
    public ResponseEntity<Child> getChildById(@PathVariable int id){
        Child child = childService.getChildById(id);
        if(child != null)
            return new ResponseEntity<>(child, HttpStatus.OK);
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
    public ResponseEntity<String> deleteChild(@PathVariable int id){
        String result = childService.deleteChild(id);
        if (result.equals("Child deleted")) {
            return new ResponseEntity<>(result, HttpStatus.OK);
        }
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
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
    public ResponseEntity<Child> selectChild(@PathVariable int id){
        Child child = childService.selectChild(id);
        if (child != null) {
            return new ResponseEntity<>(child, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e
