package org.example.backend.controller;

import org.example.backend.Dto.ChildModePinDto;
import org.example.backend.Dto.auth.AuthResponseDto;
import org.example.backend.Dto.auth.LoginDto;
import org.example.backend.Dto.auth.RefreshTokenDto;
import org.example.backend.Dto.auth.RegisterDto;
import org.example.backend.model.Child;
import org.example.backend.model.Parent;
import org.example.backend.service.AuthService;
import org.example.backend.service.ChildService;
import org.example.backend.service.ParentService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
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


    @GetMapping("/isChildMode")
    public ResponseEntity<Boolean> isChildMode() {
        return ResponseEntity.ok(userService.isChildMode());
    }

    @PostMapping("/childMode/enable")
    public ResponseEntity<String> enableChildMode() {
        Parent parent = userService.setChildMode(true);
        if (parent.getChildModePin() == null) {
            return ResponseEntity.badRequest().body("PIN is needed to enable child mode");
        }
        return ResponseEntity.ok("Child mode enabled");
    }

    @PostMapping("/childMode/disable")
    public ResponseEntity<String> disableChildMode(@RequestBody ChildModePinDto dto) {
        if (!userService.verifyChildModePin(dto.getPin())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Incorrect PIN");
        }
        userService.setChildMode(false);
        return ResponseEntity.ok("Child mode disabled");
    }

    @PostMapping("/childMode/setPin")
    public ResponseEntity<String> setChildModePin(@RequestBody ChildModePinDto dto) {
        String result = userService.setChildModePin(dto.getPin());
        if (result.equals("PIN set successfully")) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }

    @GetMapping("/childMode/hasPin")
    public ResponseEntity<Boolean> hasPin() {
        return ResponseEntity.ok(userService.hasPinSet());
    }
}