package org.example.backend.service;

import org.example.backend.Dto.RegisterDto;
import org.example.backend.config.PasswordEncoderConfig;
import org.example.backend.model.User;
import org.example.backend.model.UserPrincipal;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.UserRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;


@Service
public class UserService implements UserDetailsService {

    @Autowired
    private UserRepo repo;

    @Autowired
    private PasswordEncoderConfig passwordEncoderConfig;
    @Autowired
    private ChildRepo childRepo;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        User user = repo.findByEmail(email);

        if(user == null) {
            System.out.println("User not found");
            throw new UsernameNotFoundException("User not found");
        }

        return new UserPrincipal(user);
    }

    public String register(RegisterDto registerDto) {
        if(repo.findByEmail(registerDto.getEmail()) != null) {
            return "Email already exists";
        }
        User user = new User();

        user.setEmail(registerDto.getEmail());
        user.setPassword(passwordEncoderConfig.passwordEncoder().encode(registerDto.getPassword()));
        user.setName(registerDto.getName());
        user.setGender(registerDto.getGender());

        repo.save(user);
        return "User registered successfully";
    }

    public boolean isNewUser() {
        User user = SecurityUtils.getCurrentUser();

        if(childRepo.findByUserId(user.getId()).isEmpty()) {
            return true;
        }
        return false;
    }
}
