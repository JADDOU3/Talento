// lib/cubits/reviews/kit_reviews_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/models/review_model.dart';
import '../../shared/services/api_service.dart';
import 'kit_reviews_state.dart';

/// Loads reviews independently from kit details (`GET /api/reviews/kit/{id}`).
class KitReviewsCubit extends Cubit<KitReviewsState> {
  KitReviewsCubit() : super(const KitReviewsInitial());

  Future<void> loadForKit(int kitId) async {
    emit(const KitReviewsLoading());

    final reviewsResult = await ApiService.getWithStatus('/reviews/kit/$kitId');
    final ratingResult =
    await ApiService.getWithStatus('/reviews/kit/$kitId/rating');

    if (reviewsResult.isNetworkFailure && ratingResult.isNetworkFailure) {
      emit(const KitReviewsHidden());
      return;
    }

    if (reviewsResult.status == 404 || ratingResult.status == 404) {
      emit(const KitReviewsHidden());
      return;
    }

    final reviews = _parseReviews(reviewsResult.body);
    final summary = _parseRating(ratingResult.body, reviews);

    if (reviews.isEmpty && summary.totalReviews == 0) {
      emit(const KitReviewsEmpty());
      return;
    }

    emit(KitReviewsLoaded(
      reviews: reviews,
      averageRating: summary.averageRating,
      totalReviews: summary.totalReviews,
    ));
  }

  /// Submit a new review for a kit
  Future<bool> submitReview(int kitId, int rating, String comment) async {
    debugPrint('🔄 submitReview called: kitId=$kitId, rating=$rating');
    debugPrint('📝 Comment: $comment');

    try {
      final Map<String, dynamic> body = {
        'kitId': kitId,
        'rating': rating,
        'comment': comment,
      };

      debugPrint('📤 Sending review: $body');

      final result = await ApiService.postWithStatus('/reviews/', body);

      debugPrint('📥 Review response: status=${result.status}, isSuccess=${result.isSuccess}');
      debugPrint('📥 Response body: ${result.body}');
      debugPrint('📥 Raw text: ${result.rawText}');

      if (result.isSuccess) {
        debugPrint('✅ Review submitted successfully!');
        // Reload reviews after successful submission
        await loadForKit(kitId);
        return true;
      } else {
        final message = ApiService.decodeResponseBody(result.rawText)['message']
            ?? 'Failed to submit review';
        debugPrint('❌ Review failed: $message');
        emit(KitReviewsError(message));
        return false;
      }
    } catch (e) {
      debugPrint('❌ Review error: $e');
      emit(KitReviewsError(e.toString()));
      return false;
    }
  }

  List<ReviewModel> _parseReviews(dynamic body) {
    if (body is List) {
      return body
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();
    }
    if (body is Map<String, dynamic>) {
      final content = body['content'];
      if (content is List) {
        return content
            .whereType<Map<String, dynamic>>()
            .map(ReviewModel.fromJson)
            .toList();
      }
    }
    return [];
  }

  KitRatingSummary _parseRating(dynamic body, List<ReviewModel> reviews) {
    if (body is Map<String, dynamic>) {
      return KitRatingSummary.fromJson(body);
    }
    if (reviews.isEmpty) {
      return const KitRatingSummary(averageRating: 0, totalReviews: 0);
    }
    final avg =
        reviews.fold<double>(0, (s, r) => s + r.rating) / reviews.length;
    return KitRatingSummary(
      averageRating: avg,
      totalReviews: reviews.length,
    );
  }
}