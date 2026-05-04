package org.example.backend.repo;


import org.example.backend.model.Child;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ChildRepo extends JpaRepository<Child, Integer> {
    List<Child> findByUserId(int userId);
}
