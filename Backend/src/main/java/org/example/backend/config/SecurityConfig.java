package org.example.backend.config;

import org.example.backend.service.ParentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private ParentService userService;

    @Autowired
    private PasswordEncoderConfig passwordEncoderConfig;

    @Autowired
    private JwtFilter jwtFilter;

    @Autowired
    private ChildModeFilter childModeFilter;

    @Autowired
    private RestAuthenticationEntryPoint restAuthenticationEntryPoint;

    @Autowired
    private RestAccessDeniedHandler restAccessDeniedHandler;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return  http.csrf(customizer -> customizer.disable())
                    .cors(Customizer.withDefaults())
                    .authorizeHttpRequests(request ->
                        request.requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                                .requestMatchers("/api/login", "/api/register", "/api/refresh").permitAll()
                                .requestMatchers( "/api/mindsets", "/api/criteria", "/api/activity-criteria").permitAll()
                                .anyRequest().authenticated())
                    .exceptionHandling(exceptions -> exceptions
                            .authenticationEntryPoint(restAuthenticationEntryPoint)
                            .accessDeniedHandler(restAccessDeniedHandler))
                     .httpBasic(Customizer.withDefaults())
                     .sessionManagement(session ->
                             session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                     .addFilterBefore(jwtFilter ,  UsernamePasswordAuthenticationFilter.class)
                     .addFilterAfter(childModeFilter, JwtFilter.class)
                     .build();
    }


    @Bean
    public AuthenticationProvider authenticationProvider(){
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider(userService);
        provider.setPasswordEncoder(passwordEncoderConfig.passwordEncoder());
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception{

        return config.getAuthenticationManager();


    }
}
