<<<<<<< HEAD:Backend/src/main/java/org/example/backend/model/UserPrincipal.java
package org.example.backend.model;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
public class UserPrincipal implements UserDetails {

    private User user;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public @Nullable String getPassword() {
        return user.getPassword();
    }

    @Override
    public String getUsername() {
        return user.getEmail();
    }
}
=======
package org.example.backend.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Data
public class ParentPrincipal implements UserDetails {

    private Parent parent;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of();
    }

    @Override
    public @Nullable String getPassword() {
        return parent.getPassword();
    }

    @Override
    public String getUsername() {
        return parent.getEmail();
    }

    public Parent getParent() {
        return parent;
    }
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e:Backend/src/main/java/org/example/backend/model/ParentPrincipal.java
