<<<<<<< HEAD:Backend/src/main/java/org/example/backend/repo/ActivityRepo.java
package org.example.backend.repo;

import org.example.backend.model.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;


@Repository
public interface ActivityRepo extends JpaRepository<Activity, Integer> {

}
=======
package org.example.backend.repo.activity;

import org.example.backend.model.activity.Activity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface ActivityRepo extends JpaRepository<Activity, Integer> {
    List<Activity> findByKitId(int kitId);
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e:Backend/src/main/java/org/example/backend/repo/activity/ActivityRepo.java
