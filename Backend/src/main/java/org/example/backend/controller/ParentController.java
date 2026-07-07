package org.example.backend.controller;

import org.example.backend.Dto.parent.ChildModePinDto;
import org.example.backend.Dto.parent.UpdatePasswordDto;
import org.example.backend.Dto.parent.UpdateProfileDto;
import org.example.backend.Dto.auth.AuthResponseDto;
import org.example.backend.Dto.auth.LoginDto;
import org.example.backend.Dto.auth.RefreshTokenDto;
import org.example.backend.Dto.auth.RegisterDto;
import org.example.backend.Dto.auth.ParentProfileDto;
import org.example.backend.service.AuthService;
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
    public ResponseEntity<ParentProfileDto> getCurrentUser() {
        return ResponseEntity.ok(ParentProfileDto.from(SecurityUtils.getCurrentUser()));
    }


    @GetMapping("/isChildMode")
    public ResponseEntity<Boolean> isChildMode() {
        return ResponseEntity.ok(userService.isChildMode());
    }

    @PostMapping("/childMode/enable")
    public ResponseEntity<String> enableChildMode() {
        var parent = userService.setChildMode(true);
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

    @PostMapping("/childMode/verifyPin")
    public ResponseEntity<String> verifyChildModePin(@RequestBody ChildModePinDto dto) {
        if (!userService.verifyChildModePin(dto.getPin())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Incorrect PIN");
        }
        return ResponseEntity.ok("PIN correct");
    }

    @PostMapping("/legal/privacy-policy/accept")
    public ResponseEntity<String> acceptPrivacyPolicy() {
        return ResponseEntity.ok(userService.acceptPrivacyPolicy());
    }

    @GetMapping("/legal/privacy-policy/accepted")
    public ResponseEntity<Boolean> hasAcceptedPrivacyPolicy() {
        return ResponseEntity.ok(userService.hasPrivacyPolicyAccepted());
    }

    @PutMapping("/profile")
    public ResponseEntity<String> updateProfile(@RequestBody UpdateProfileDto dto) {
        return ResponseEntity.ok(userService.updateProfile(dto));
    }

    @PutMapping("/password")
    public ResponseEntity<String> updatePassword(@RequestBody UpdatePasswordDto dto) {
        String result = userService.updatePassword(dto);
        if (result.equals("Password updated successfully")) {
            return ResponseEntity.ok(result);
        }
        return ResponseEntity.badRequest().body(result);
    }
}