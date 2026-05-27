package org.example.backend.controller.activity;


import org.example.backend.Dto.activity.AssignActivityToKitDto;
import org.example.backend.Dto.activity.CreateActivityDto;
import org.example.backend.Dto.activity.UpdateActivityDto;
import org.example.backend.model.activity.Activity;
import org.example.backend.service.activity.ActivityService;
import org.example.backend.service.KitService;
import org.example.backend.util.PaginationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/activities")
public class ActivityController {

    @Autowired
    private ActivityService activityService;
    @Autowired
    private KitService kitService;

    @PostMapping("/")
    public ResponseEntity<Activity> createActivity(@RequestBody CreateActivityDto createActivityDto){
          Activity activity = activityService.createActivity(createActivityDto);
          return new ResponseEntity<>(activity , HttpStatus.CREATED);
    }


    @GetMapping("/{id}")
    public ResponseEntity<Activity> getActivityById(@PathVariable int id){
        Activity activity = activityService.getActivityById(id);
        if(activity == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(activity , HttpStatus.OK);
    }


    @GetMapping("/")
    public ResponseEntity<Page<Activity>> getAllActivities(Pageable pageable){
        List<Activity> activities = activityService.getAllActivities();
        return new ResponseEntity<>(PaginationUtil.paginate(activities, pageable) , HttpStatus.OK);
    }


    @PutMapping("/")
    public ResponseEntity<Activity> updateActivity(@RequestBody UpdateActivityDto updateActivityDto){
        Activity activity = activityService.updateActivity(updateActivityDto);
        return new ResponseEntity<>(activity , HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteActivity(@PathVariable int id){
        activityService.deleteActivity(id);
        return new ResponseEntity<>("Activity deleted successfully" , HttpStatus.OK);
    }

    @PutMapping("/kit/")
    public ResponseEntity<Activity> assignActivityToKit(@RequestBody AssignActivityToKitDto assignActivityToKitDto){
        if(activityService.getActivityById(assignActivityToKitDto.getActivityId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);

        if(kitService.getKitById(assignActivityToKitDto.getKitId()) == null)
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        return new ResponseEntity<>(activityService.assignActivityToKit(assignActivityToKitDto) , HttpStatus.OK);
        }


    @GetMapping("/kit/{kitId}")
    public ResponseEntity<Page<Activity>> getAllActivitiesByKit(@PathVariable int kitId, Pageable pageable){
        List<Activity> activities = activityService.getActivitiesByKit(kitId);
        if(activities != null)
            return new ResponseEntity<>(PaginationUtil.paginate(activities, pageable) , HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

}
