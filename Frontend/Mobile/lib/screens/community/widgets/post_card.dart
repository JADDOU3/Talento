import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PostCard extends StatelessWidget {
  final String user;
  final String time;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final int likes;

  const PostCard({
    super.key,
    required this.user,
    required this.time,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.inputFill,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 10.5,
                        color: AppColors.hint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 22),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.18,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.inputFill,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.pink, size: 22),
              const SizedBox(width: 5),
              Text(
                likes.toString(),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 18),
              Icon(Icons.mode_comment_outlined, color: AppColors.textSecondary, size: 21),
              const SizedBox(width: 18),
              Icon(Icons.share_outlined, color: AppColors.textSecondary, size: 21),
            ],
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.3,
                height: 1.55,
              ),
              children: [
                TextSpan(
                  text: '$user  ',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                TextSpan(text: caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
