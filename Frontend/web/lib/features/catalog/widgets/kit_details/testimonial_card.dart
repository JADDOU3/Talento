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
    this.childName,
    this.childAge,
    this.childImage,
  });

  final double rating;
  final String reviewText;
  final String name;
  final String role;
  final DateTime? createdAt;
  final String? childName;
  final int? childAge;
  final String? childImage;

  @override
  Widget build(BuildContext context) {
    final dateLabel = createdAt != null
        ? DateFormat.yMMMd().format(createdAt!.toLocal())
        : null;

    // Generate random fun emoji based on name for variety
    final funEmoji = _getFunEmoji(name);

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
        border: Border.all(
          color: AppColors.cartTeal.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fun header with emoji and rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                funEmoji,
                style: const TextStyle(fontSize: 24),
              ),
              StarRating(
                rating: rating,
                size: 20,
                spacing: 3,
                filledColor: AppColors.cartTotalRose,
                emptyColor: AppColors.cartTotalRose.withValues(alpha: 0.25),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Review text with quote marks
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '"',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cartTeal,
                  height: 0.8,
                ),
              ),
              Expanded(
                child: Text(
                  reviewText,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const Text(
                '"',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cartTeal,
                  height: 0.8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Child info if available
          if (childName != null) ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.cartTeal.withValues(alpha: 0.2),
                        AppColors.cartTeal.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.cartTeal.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: childImage != null && childImage!.isNotEmpty
                      ? ClipOval(
                    child: Image.network(
                      childImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _childAvatarPlaceholder(),
                    ),
                  )
                      : _childAvatarPlaceholder(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        childName!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.cartTeal,
                        ),
                      ),
                      if (childAge != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '🎂 ${childAge! - 2}-${childAge! + 2} years',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.cartMutedGrey.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Parent info
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.cartTeal.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.cartTeal,
                ),
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
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 10,
                            color: AppColors.cartMutedGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Fun verification badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cartTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.cartTeal.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified,
                      size: 12,
                      color: AppColors.cartTeal,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cartTeal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Fun footer with tags
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildTag('⭐ Parent Approved'),
              _buildTag('🌈 Kid Loved'),
              if (childName != null) _buildTag('👶 ${childName!.split(' ').first}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cartTeal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.cartTeal.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.cartTeal.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  Widget _childAvatarPlaceholder() {
    return Center(
      child: Icon(
        Icons.face_rounded,
        size: 22,
        color: AppColors.cartTeal.withValues(alpha: 0.5),
      ),
    );
  }

  String _getFunEmoji(String name) {
    final emojis = ['🌟', '⭐', '🌈', '🎯', '💡', '🎨', '🚀', '🎪', '🎠', '🎈', '🎀', '🧸'];
    final index = name.length % emojis.length;
    return emojis[index];
  }
}

/// Alternative compact version for list views
class TestimonialCompactCard extends StatelessWidget {
  const TestimonialCompactCard({
    super.key,
    required this.rating,
    required this.reviewText,
    required this.name,
    required this.role,
    this.childName,
  });

  final double rating;
  final String reviewText;
  final String name;
  final String role;
  final String? childName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.cartTeal.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.cartTeal,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                StarRating(
                  rating: rating,
                  size: 14,
                  spacing: 2,
                  filledColor: AppColors.cartTotalRose,
                  emptyColor: AppColors.cartTotalRose.withValues(alpha: 0.25),
                ),
                const SizedBox(height: 6),
                // Review
                Text(
                  reviewText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 6),
                // Name and role
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.cartTeal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $role',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.cartMutedGrey,
                      ),
                    ),
                    if (childName != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '👶 $childName',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cartMutedGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Fun emoji
          Text(
            ['🌟', '⭐', '🌈', '🎯'][rating.round() % 4],
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}