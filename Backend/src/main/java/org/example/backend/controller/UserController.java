package org.example.backend.controller;

import org.example.backend.Dto.auth.AuthResponseDto;
import org.example.backend.Dto.auth.LoginDto;
import org.example.backend.Dto.auth.RegisterDto;
import org.example.backend.model.User;
import org.example.backend.service.AuthService;
import org.example.backend.service.UserService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public String register(@RequestBody RegisterDto registerDto) {
        return userService.register(registerDto);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginDto loginDto) {
        return ResponseEntity.ok(authService.login(loginDto));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponseDto> refresh(@RequestBody String refreshToken) {
        return ResponseEntity.ok(authService.refresh(refreshToken));
    }

    @GetMapping("/isNewUser")
    public boolean isNewUser() {
        return userService.isNewUser();
    }

    @GetMapping("/currentUser")
    public User getCurrentUser() {
        return SecurityUtils.getCurrentUser();
    }
}