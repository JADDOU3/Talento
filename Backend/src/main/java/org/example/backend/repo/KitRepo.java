package org.example.backend.repo;


import org.example.backend.model.Kit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface KitRepo extends JpaRepository<Kit, Integer> {


}
