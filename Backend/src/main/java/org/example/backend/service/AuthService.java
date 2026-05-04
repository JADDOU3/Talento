<<<<<<< HEAD
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
=======
package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.auth.AuthResponseDto;
import org.example.backend.Dto.auth.LoginDto;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final JWTService jwtService;
    private final UserDetailsService userDetailsService;

    public AuthResponseDto login(LoginDto loginDto) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(loginDto.getEmail(), loginDto.getPassword())
        );

        if (!authentication.isAuthenticated()) {
            throw new RuntimeException("Invalid credentials");
        }

        return new AuthResponseDto(
                jwtService.generateToken(loginDto.getEmail()),
                jwtService.generateRefreshToken(loginDto.getEmail())
        );
    }

    public AuthResponseDto refresh(String refreshToken) {
        String email = jwtService.extractUsername(refreshToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(email);

        if (!jwtService.validateToken(refreshToken, userDetails)) {
            throw new RuntimeException("Invalid or expired refresh token");
        }

        return new AuthResponseDto(
                jwtService.generateToken(email),
                refreshToken
        );
    }
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e
