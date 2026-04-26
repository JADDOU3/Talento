package org.example.backend.repo;

import org.example.backend.model.Child;
import org.example.backend.model.ChildKit;
import org.example.backend.model.Kit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChildKitRepo extends JpaRepository<ChildKit, Integer> {
    List<ChildKit> findByChildId(int childId);
    List<ChildKit> findByKitId(int kitId);
    boolean existsByChildAndKit(Child child, Kit kit);
    void deleteByChildAndKit(Child child, Kit kit);
}