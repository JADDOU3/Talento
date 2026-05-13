package org.example.backend.repo;

import org.example.backend.model.Child;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChildRepo extends JpaRepository<Child, Integer> {
    List<Child> findByParentId(int id);
    Child findByIsSelectedTrueAndParentId(int parentId);

    @Modifying
    @Query("UPDATE Child c SET c.isSelected = false WHERE c.parent.id = :parentId")
    void deselectAllByParentId(@Param("parentId") int parentId);
}
