package org.example.backend.controller;

import org.example.backend.Dto.ContactUsDto;
import org.example.backend.service.ContactService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ContactController {

    @Autowired
    private ContactService contactService;

    @PostMapping("/contact")
    public ResponseEntity<String> contactUs(@RequestBody ContactUsDto dto) {
        String result = contactService.sendContactMessage(dto);
        return ResponseEntity.ok(result);
    }
}