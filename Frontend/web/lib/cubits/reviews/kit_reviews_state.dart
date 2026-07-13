// lib/cubits/reviews/kit_reviews_state.dart
import '../../shared/models/review_model.dart';

class KitRatingSummary {
  final double averageRating;
  final int totalReviews;

  const KitRatingSummary({
    required this.averageRating,
    required this.totalReviews,
  });

  factory KitRatingSummary.fromJson(Map<String, dynamic> json) {
    return KitRatingSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }
}

abstract class KitReviewsState {
  const KitReviewsState();
}

class KitReviewsInitial extends KitReviewsState {
  const KitReviewsInitial();
}

class KitReviewsLoading extends KitReviewsState {
  const KitReviewsLoading();
}

class KitReviewsLoaded extends KitReviewsState {
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  const KitReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });
}

class KitReviewsEmpty extends KitReviewsState {
  const KitReviewsEmpty();
}

class KitReviewsHidden extends KitReviewsState {
  const KitReviewsHidden();
}

class KitReviewsError extends KitReviewsState {
  final String message;
  const KitReviewsError(this.message);
}