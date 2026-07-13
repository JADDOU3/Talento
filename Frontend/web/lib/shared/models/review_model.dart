// lib/shared/models/review_model.dart
class ReviewModel {
  final int id;
  final int kitId;
  final String kitName;
  final int parentId;
  final String parentName;
  final int rating;
  final String comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.kitId,
    required this.kitName,
    required this.parentId,
    required this.parentName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as int? ?? 0,
      kitId: json['kitId'] as int? ?? 0,
      kitName: json['kitName'] as String? ?? '',
      parentId: json['parentId'] as int? ?? 0,
      parentName: json['parentName'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  String get stars {
    return '★' * rating + '☆' * (5 - rating);
  }
}