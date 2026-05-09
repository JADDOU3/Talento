package org.example.backend.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.example.backend.model.Parent;
import org.example.backend.util.SecurityUtils;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class ChildModeFilter extends OncePerRequestFilter {

    private static final List<String> CHILD_MODE_RESTRICTED = List.of(
            "/api/performances",
            "/api/ai-reports",
            "/api/child-mindset-scores",
            "/api/criteria",
            "/api/mindsets",
            "/api/activity-criteria"
    );

    private static final List<String> CHILD_MODE_READ_ONLY = List.of(
            "/api/posts",
            "/api/comments",
            "/api/likes"
    );

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getRequestURI();
        String method = request.getMethod();

        boolean isRestricted = CHILD_MODE_RESTRICTED.stream()
                .anyMatch(path::startsWith);

        boolean isReadOnlyViolation = CHILD_MODE_READ_ONLY.stream()
                .anyMatch(path::startsWith)
                && !method.equals("GET");

        if (isRestricted || isReadOnlyViolation) {
            try {
                Parent parent = SecurityUtils.getCurrentUser();
                if (parent != null && parent.isChildModeEnabled()) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json");
                    response.getWriter().write(
                            "{\"error\": \"Access denied: child mode is enabled\"}"
                    );
                    return;
                }
            } catch (Exception e) {
                // JwtFilter handles unauthenticated requests
            }
        }

        filterChain.doFilter(request, response);
    }
}