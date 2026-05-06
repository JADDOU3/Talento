package org.example.backend.repo.community;

import org.example.backend.model.community.Media;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MediaRepo extends JpaRepository<Media, Integer> {
}
