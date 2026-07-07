package org.example.backend.controller;

import lombok.RequiredArgsConstructor;
import org.example.backend.service.LegalService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class LegalController {

    private final LegalService legalService;

    @GetMapping("/legal/privacy-policy")
    public ResponseEntity<String> getPrivacyPolicyUrl() {
        return ResponseEntity.ok(legalService.getPrivacyPolicyUrl());
    }
}