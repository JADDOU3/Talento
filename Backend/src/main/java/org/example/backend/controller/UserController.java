package org.example.backend.controller;


import org.example.backend.Dto.LoginDto;
import org.example.backend.Dto.RegisterDto;
import org.example.backend.model.User;
import org.example.backend.service.AuthService;
import org.example.backend.service.UserService;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
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
    public String Login(@RequestBody LoginDto loginDto){
        return authService.login(loginDto);
    }

    @GetMapping("/isNewUser")
    public boolean isNewUser(){
        return userService.isNewUser();
    }

    @GetMapping("/currentUser")
    public User getCurrentUser(){
        User user = SecurityUtils.getCurrentUser();
        return user;
    }


}
