import '../../shared/models/review_model.dart';

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

/// Hard failure — section should be hidden.
class KitReviewsHidden extends KitReviewsState {
  const KitReviewsHidden();
}
