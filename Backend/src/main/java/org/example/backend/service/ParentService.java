package org.example.backend.service;

import org.example.backend.Dto.auth.RegisterDto;
import org.example.backend.config.PasswordEncoderConfig;
import org.example.backend.model.Parent;
import org.example.backend.model.ParentPrincipal;
import org.example.backend.repo.ChildRepo;
import org.example.backend.repo.ParentRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;


@Service
public class ParentService implements UserDetailsService {

    @Autowired
    private ParentRepo repo;

    @Autowired
    private PasswordEncoderConfig passwordEncoderConfig;
    @Autowired
    private ChildRepo childRepo;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        Parent parent = repo.findByEmail(email);

        if(parent == null) {
            System.out.println("Parent not found");
            throw new UsernameNotFoundException("Parent not found");
        }

        return new ParentPrincipal(parent);
    }

    public String register(RegisterDto registerDto) {
        if(repo.findByEmail(registerDto.getEmail()) != null) {
            return "Email already exists";
        }
        Parent parent = new Parent();

        parent.setEmail(registerDto.getEmail());
        parent.setPassword(passwordEncoderConfig.passwordEncoder().encode(registerDto.getPassword()));
        parent.setName(registerDto.getName());
        parent.setGender(registerDto.getGender());
        parent.setCreatedAt(LocalDateTime.now());

        repo.save(parent);
        return "Parent registered successfully";
    }

    public boolean isNewUser() {
        Parent parent = SecurityUtils.getCurrentUser();

        if(childRepo.findByParentId(parent.getId()).isEmpty()) {
            return true;
        }
        return false;
    }
}
