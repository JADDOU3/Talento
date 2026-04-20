package org.example.backend.repo;


import org.example.backend.model.Kit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KitRepo extends JpaRepository<Kit, Integer> {
    List<Kit> findByChildId(int childId);
}
