package org.example.backend.controller;

import org.example.backend.Dto.auth.AuthResponseDto;
import org.example.backend.Dto.auth.LoginDto;
import org.example.backend.Dto.auth.RefreshTokenDto;
import org.example.backend.Dto.auth.RegisterDto;
import org.example.backend.model.Parent;
import org.example.backend.service.AuthService;
import org.example.backend.service.ParentService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ParentController {

    @Autowired
    private ParentService userService;

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<String> register(@RequestBody RegisterDto registerDto) {
        String result = userService.register(registerDto);
        if (result.equals("Parent registered successfully")) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginDto loginDto) {
        return ResponseEntity.ok(authService.login(loginDto));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponseDto> refresh(@RequestBody RefreshTokenDto refreshTokenDto ) {
        return ResponseEntity.ok(authService.refresh(refreshTokenDto.getRefreshToken()));
    }

    @GetMapping("/isNewUser")
    public ResponseEntity<Boolean> isNewUser() {
        return ResponseEntity.ok(userService.isNewUser());
    }

    @GetMapping("/currentUser")
    public ResponseEntity<Parent> getCurrentUser() {
        return ResponseEntity.ok(SecurityUtils.getCurrentUser());
    }
}