<<<<<<< HEAD:Backend/src/main/java/org/example/backend/repo/UserRepo.java
package org.example.backend.repo;

import org.example.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepo extends JpaRepository<User, Integer> {

    User findByEmail(String email);
}
=======
package org.example.backend.repo;

import org.example.backend.model.Parent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ParentRepo extends JpaRepository<Parent, Integer> {

    Parent findByEmail(String email);
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e:Backend/src/main/java/org/example/backend/repo/ParentRepo.java
