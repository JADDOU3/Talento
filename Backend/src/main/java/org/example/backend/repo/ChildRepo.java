package org.example.backend.repo;

import org.example.backend.model.Child;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChildRepo extends JpaRepository<Child, Integer> {
    List<Child> findByUserId(int id);
    Child findByIsSelectedTrueAndUserId(int userId);

    @Modifying
    @Query("UPDATE Child c SET c.isSelected = false WHERE c.user.id = :userId")
    void deselectAllByUserId(@Param("userId") int userId);
}
