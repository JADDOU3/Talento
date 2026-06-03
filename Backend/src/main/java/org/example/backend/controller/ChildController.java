package org.example.backend.controller;

import org.example.backend.Dto.child.ChildResponseDto;
import org.example.backend.Dto.child.ChildUpdateDto;
import org.example.backend.Dto.child.CreateChildDto;
import org.example.backend.service.ChildService;
import org.example.backend.util.PaginationUtil;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/children")
public class ChildController {
    @Autowired
    private ChildService childService;

    @GetMapping("/{id}")
    public ResponseEntity<ChildResponseDto> getChildById(@PathVariable int id) {
        ChildResponseDto child = childService.getChildResponseById(id);
        if (child != null)
            return new ResponseEntity<>(child, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @GetMapping
    public ResponseEntity<Page<ChildResponseDto>> getChildrenByCurrentUser(Pageable pageable) {
        var children = childService.getAllChildrenByUser(SecurityUtils.getCurrentUser().getId());
        if (children != null)
            return new ResponseEntity<>(PaginationUtil.paginate(children, pageable), HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("/")
    public ResponseEntity<ChildResponseDto> addChild(@RequestBody CreateChildDto childDto) {
        return new ResponseEntity<>(childService.createChild(childDto), HttpStatus.CREATED);
    }

    @PutMapping("/")
    public ResponseEntity<ChildResponseDto> updateChild(@RequestBody ChildUpdateDto childUpdateDto) {
        ChildResponseDto child = childService.updateChild(childUpdateDto);
        if (child != null)
            return new ResponseEntity<>(child, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteChild(@PathVariable int id) {
        String result = childService.deleteChild(id);
        if (result.equals("Child deleted")) {
            return new ResponseEntity<>(result, HttpStatus.OK);
        }
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }

    @GetMapping("/selected")
    public ResponseEntity<ChildResponseDto> getSelectedChild() {
        ChildResponseDto child = childService.getSelectedChildResponse();
        if (child != null)
            return new ResponseEntity<>(child, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PutMapping("/selected/{id}")
    public ResponseEntity<ChildResponseDto> selectChild(@PathVariable int id) {
        ChildResponseDto child = childService.selectChild(id);
        if (child != null) {
            return new ResponseEntity<>(child, HttpStatus.OK);
        }
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }
}
