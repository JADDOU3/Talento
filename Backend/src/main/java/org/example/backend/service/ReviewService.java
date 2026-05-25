package org.example.backend.service;

import org.example.backend.Dto.Review.CreateReviewDto;
import org.example.backend.Dto.Review.ReviewDto;
import org.example.backend.Dto.Review.UpdateReviewDto;
import org.example.backend.model.Kit;
import org.example.backend.model.Parent;
import org.example.backend.model.Review;
import org.example.backend.repo.KitRepo;
import org.example.backend.repo.ReviewRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class ReviewService {

    @Autowired
    private ReviewRepo reviewRepo;
    @Autowired
    private KitRepo kitRepo;

    public List<ReviewDto> getAllReviews() {
        List<Review> reviews=reviewRepo.findAll();
        List<ReviewDto> dtos=new ArrayList<>();
        for (Review review : reviews) {
            dtos.add(toReviewDto(review));
        }
        return dtos;
    }

    public List<ReviewDto> getReviewsByKit(int kitId) {
        List<Review> reviews=reviewRepo.findByKitId(kitId);
        List<ReviewDto> dtos=new ArrayList<>();
        for (Review review : reviews) {
            dtos.add(toReviewDto(review));
        }
        return dtos;
    }

    public List<ReviewDto> getMyReviews() {
        int parentId=SecurityUtils.getCurrentUser().getId();
        List<Review> reviews=reviewRepo.findByParentId(parentId);
        List<ReviewDto> dtos=new ArrayList<>();
        for (Review review : reviews) {
            dtos.add(toReviewDto(review));
        }
        return dtos;
    }

    public ReviewDto getReviewById(int id) {
        Review review=reviewRepo.findById(id).orElse(null);
        if (review==null) return null;
        return toReviewDto(review);
    }

    public ReviewDto createReview(CreateReviewDto dto) {
        Parent parent=SecurityUtils.getCurrentUser();

        Kit kit=kitRepo.findById(dto.getKitId()).orElse(null);
        if (kit==null) return null;

        if (dto.getRating()<1 || dto.getRating()>5) return null;

        List<Review> existing=reviewRepo.findByParentIdAndKitId(parent.getId(), dto.getKitId());
        if (!existing.isEmpty()) return null;

        Review review=new Review();
        review.setParent(parent);
        review.setKit(kit);
        review.setRating(dto.getRating());
        review.setComment(dto.getComment());
        reviewRepo.save(review);

        updateKitRating(kit.getId());
        return toReviewDto(review);
    }

    public ReviewDto updateReview(int id, UpdateReviewDto dto) {
        int parentId=SecurityUtils.getCurrentUser().getId();

        Review review=reviewRepo.findById(id).orElse(null);
        if (review==null) return null;
        if (review.getParent().getId()!=parentId) return null;

        if (dto.getRating()<1 || dto.getRating()>5) return null;

        review.setRating(dto.getRating());
        review.setComment(dto.getComment());
        reviewRepo.save(review);

        updateKitRating(review.getKit().getId());
        return toReviewDto(review);
    }

    public void deleteReview(int id) {
        int parentId=SecurityUtils.getCurrentUser().getId();

        Review review=reviewRepo.findById(id).orElse(null);
        if (review==null) return;
        if (review.getParent().getId()!=parentId) return;

        int kitId=review.getKit().getId();
        reviewRepo.delete(review);
        updateKitRating(kitId);
    }

    public double getAverageRating(int kitId) {
        List<Review> reviews=reviewRepo.findByKitId(kitId);
        if (reviews.isEmpty()) return 0;
        double total=0;
        for (Review review : reviews) {
            total+=review.getRating();
        }
        return total/reviews.size();
    }

    private void updateKitRating(int kitId) {
        List<Review> reviews=reviewRepo.findByKitId(kitId);
        Kit kit=kitRepo.findById(kitId).orElse(null);
        if (kit==null) return;
        if (reviews.isEmpty()) {
            kit.setRating(0);
        } else {
            double total=0;
            for (Review review : reviews) {
                total+=review.getRating();
            }
            kit.setRating((int) Math.round(total/reviews.size()));
        }
        kitRepo.save(kit);
    }

    private ReviewDto toReviewDto(Review review) {
        ReviewDto dto=new ReviewDto();
        dto.setId(review.getId());
        dto.setKitId(review.getKit().getId());
        dto.setKitName(review.getKit().getName());
        dto.setParentId(review.getParent().getId());
        dto.setParentName(review.getParent().getName());
        dto.setRating(review.getRating());
        dto.setComment(review.getComment());
        dto.setCreatedAt(review.getCreatedAt());
        return dto;
    }
}