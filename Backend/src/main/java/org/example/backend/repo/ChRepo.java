package org.example.backend.repo;


import org.example.backend.model.Child;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChRepo extends JpaRepository<Child, Integer> {
    List<Child> findByParentId(int parentId);
}
