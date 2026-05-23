package org.example.backend.controller;

import org.example.backend.Dto.Review.CreateReviewDto;
import org.example.backend.Dto.Review.ReviewDto;
import org.example.backend.Dto.Review.UpdateReviewDto;
import org.example.backend.service.ReviewService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    @Autowired
    private ReviewService reviewService;

    @GetMapping("/")
    public ResponseEntity<List<ReviewDto>> getAllReviews() {
        return new ResponseEntity<>(reviewService.getAllReviews(), HttpStatus.OK);
    }

    @GetMapping("/kit/{kitId}")
    public ResponseEntity<List<ReviewDto>> getReviewsByKit(@PathVariable int kitId) {
        return new ResponseEntity<>(reviewService.getReviewsByKit(kitId), HttpStatus.OK);
    }

    @GetMapping("/my")
    public ResponseEntity<List<ReviewDto>> getMyReviews() {
        return new ResponseEntity<>(reviewService.getMyReviews(), HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReviewDto> getReviewById(@PathVariable int id) {
        ReviewDto review=reviewService.getReviewById(id);
        if (review!=null)
            return new ResponseEntity<>(review, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @PostMapping("/")
    public ResponseEntity<ReviewDto> createReview(@RequestBody CreateReviewDto dto) {
        ReviewDto review=reviewService.createReview(dto);
        if (review!=null)
            return new ResponseEntity<>(review, HttpStatus.CREATED);
        return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ReviewDto> updateReview(@PathVariable int id, @RequestBody UpdateReviewDto dto) {
        ReviewDto review=reviewService.updateReview(id, dto);
        if (review!=null)
            return new ResponseEntity<>(review, HttpStatus.OK);
        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteReview(@PathVariable int id) {
        reviewService.deleteReview(id);
        return new ResponseEntity<>(HttpStatus.OK);
    }

    @GetMapping("/kit/{kitId}/rating")
    public ResponseEntity<Map<String, Object>> getKitRating(@PathVariable int kitId) {
        double average=reviewService.getAverageRating(kitId);
        List<ReviewDto> reviews=reviewService.getReviewsByKit(kitId);
        Map<String, Object> response=new HashMap<>();
        response.put("kitId", kitId);
        response.put("averageRating", average);
        response.put("totalReviews", reviews.size());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}