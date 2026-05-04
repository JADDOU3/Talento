package org.example.backend.util;

import org.example.backend.model.Parent;
import org.example.backend.model.ParentPrincipal;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

public class SecurityUtils {
    public static Parent getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated()) {
            throw new RuntimeException("Unauthenticated access");
        }

        Object principal = authentication.getPrincipal();

        if (principal instanceof ParentPrincipal parentPrincipal) {
            return parentPrincipal.getParent();
        }

        throw new RuntimeException("Invalid user in security context");
    }
}
