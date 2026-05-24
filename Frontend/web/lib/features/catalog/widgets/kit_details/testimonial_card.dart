import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../util/theme/app_colors.dart';
import 'star_rating.dart';

class TestimonialCard extends StatelessWidget {
  const TestimonialCard({
    super.key,
    required this.rating,
    required this.reviewText,
    required this.name,
    required this.role,
    this.createdAt,
  });

  final double rating;
  final String reviewText;
  final String name;
  final String role;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final dateLabel = createdAt != null
        ? DateFormat.yMMMd().format(createdAt!.toLocal())
        : null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StarRating(
            rating: rating,
            size: 20,
            spacing: 3,
            filledColor: AppColors.cartTotalRose,
            emptyColor: AppColors.cartTotalRose.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            reviewText,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.cartTeal.withValues(alpha: 0.15),
                child: const Icon(Icons.person_rounded, color: AppColors.cartTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cartTeal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: AppColors.cartMutedGrey,
                      ),
                    ),
                    if (dateLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
