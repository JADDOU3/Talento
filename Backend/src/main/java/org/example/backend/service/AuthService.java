package org.example.backend.service;


import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.LoginDto;
import org.example.backend.model.User;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JWTService jwtService;

    public String login(LoginDto loginDto){
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginDto.getEmail(), loginDto.getPassword())
            );
            if (authentication.isAuthenticated()) {
                return jwtService.generateToken(loginDto.getEmail());
            }
            return "not authenticated";
        } catch (Exception e) {
            return "not authenticated";
        }
    }

}
