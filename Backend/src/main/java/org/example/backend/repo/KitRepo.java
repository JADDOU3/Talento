package org.example.backend.repo;


import org.example.backend.model.Kit;
import org.example.backend.util.enums.Mindset;
import org.example.backend.util.enums.Type;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface KitRepo extends JpaRepository<Kit, Integer> {
    List<Kit> findByChildId(int childId);
    List<Kit> findByType(Type type);
    List<Kit> findByMindset(Mindset mindset);
    List<Kit> findByNameContainingIgnoreCase(String keyword);
}
