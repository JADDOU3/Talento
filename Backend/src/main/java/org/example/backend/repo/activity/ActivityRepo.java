package org.example.backend.repo.activity;

import org.example.backend.model.activity.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ActivityRepo extends JpaRepository<Activity, Integer> {
    List<Activity> findByKitId(int kitId);
}
