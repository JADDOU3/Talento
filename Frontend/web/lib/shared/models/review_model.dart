class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.parentName,
    this.createdAt,
  });

  final int id;
  final double rating;
  final String comment;
  final String parentName;
  final DateTime? createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsed;
    final raw = json['createdAt'];
    if (raw is String && raw.isNotEmpty) {
      parsed = DateTime.tryParse(raw);
    }

    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      parentName: json['parentName'] as String? ?? '',
      createdAt: parsed,
    );
  }
}

class KitRatingSummary {
  const KitRatingSummary({
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  factory KitRatingSummary.fromJson(Map<String, dynamic> json) {
    return KitRatingSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ??
          (json['count'] as num?)?.toInt() ??
          0,
    );
  }
}
