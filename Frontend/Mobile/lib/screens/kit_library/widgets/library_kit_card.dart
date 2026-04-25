import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LibraryKitCard extends StatelessWidget {
  final String title;
  final String description;
  final String mindset;
  final String imageUrl;
  final double rating;
  final int age;
  final VoidCallback onTap;

  const LibraryKitCard({
    super.key,
    required this.title,
    required this.description,
    required this.mindset,
    required this.imageUrl,
    required this.rating,
    required this.age,
    required this.onTap,
  });

  String _mindsetArabic() {
    switch (mindset.toUpperCase()) {
      case 'BUILDER':
        return 'البنّاء';
      case 'SCIENTIST':
        return 'العالِم';
      case 'EXPLORER':
        return 'المستكشف';
      case 'INVENTOR':
        return 'المخترع';
      default:
        return mindset.isEmpty ? 'حزمة' : mindset;
    }
  }

  Color _badgeColor() {
    switch (mindset.toUpperCase()) {
      case 'BUILDER':
        return AppColors.yellow;
      case 'SCIENTIST':
        return AppColors.red;
      case 'EXPLORER':
        return AppColors.secondary;
      case 'INVENTOR':
        return AppColors.pink;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: imageUrl.isEmpty
                      ? _imagePlaceholder()
                      : Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 175,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _badge(_mindsetArabic()),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _ratingBadge(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                title,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                description,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'ابدأ الاستكشاف',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 175,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.hint,
        size: 42,
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _badgeColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _ratingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.yellow, size: 17),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}