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

    public String acceptPrivacyPolicy() {
        Parent parent = SecurityUtils.getCurrentUser();
        parent.setPrivacyPolicyAcceptedAt(LocalDateTime.now());
        repo.save(parent);
        return "Privacy policy accepted";
    }

    public boolean hasPrivacyPolicyAccepted() {
        Parent parent = SecurityUtils.getCurrentUser();
        return parent.getPrivacyPolicyAcceptedAt() != null;
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


    public String setChildModePin(String rawPin) {
        if (!rawPin.matches("\\d{6}")) {
            return "PIN must be exactly 6 digits";
        }
        Parent parent = SecurityUtils.getCurrentUser();
        parent.setChildModePin(passwordEncoderConfig.passwordEncoder().encode(rawPin));
        repo.save(parent);
        return "PIN set successfully";
    }

    public boolean verifyChildModePin(String rawPin) {
        Parent parent = SecurityUtils.getCurrentUser();
        if (parent.getChildModePin() == null) {
            return false;
        }
        return passwordEncoderConfig.passwordEncoder()
                .matches(rawPin, parent.getChildModePin());
    }

    public boolean hasPinSet() {
        Parent parent = SecurityUtils.getCurrentUser();
        return parent.getChildModePin() != null;
    }

    public Parent setChildMode(boolean enabled) {
        Parent parent = SecurityUtils.getCurrentUser();
        if(parent.getChildModePin() == null)
            return parent;
        parent.setChildModeEnabled(enabled);
        return repo.save(parent);
    }

    public boolean isChildMode() {
        Parent parent = SecurityUtils.getCurrentUser();
        return parent.isChildModeEnabled();
    }
}
