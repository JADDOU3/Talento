package org.example.backend.repo;

import org.example.backend.model.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ActivityRepo extends JpaRepository<Activity, Integer> {
    List<Activity> findByKitId(int kitId);
}
