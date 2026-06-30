import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_enums.dart';

class LibraryKitCard extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final String imageUrl;
  final double rating;
  final int age;
  final VoidCallback onTap;

  const LibraryKitCard({
    super.key,
    required this.title,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.rating,
    required this.age,
    required this.onTap,
  });

  String get _typeLabel => kitTypeArabicLabel(type);

  Color get _badgeColor {
    switch (type.toUpperCase()) {
      case 'DISCOVERY':
        return AppColors.primary;
      case 'HOBBY':
        return AppColors.pink;
      case 'DEVELOPMENT':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanDescription = description.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.055),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 230,
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: imageUrl.trim().isEmpty
                        ? _imagePlaceholder()
                        : Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 212,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return Container(
                          color: AppColors.inputFill,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    ),
                  ),
                ),
                if (_typeLabel.isNotEmpty)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _badge(_typeLabel),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _ratingBadge(),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Align(
              alignment: Alignment.center,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
            ),
            if (cleanDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              _descriptionWithMore(cleanDescription),
            ],
            const SizedBox(height: 15),
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
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _descriptionWithMore(String text) {
    final textStyle = AppTextStyles.bodyMedium.copyWith(
      height: 1.55,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: text,
            style: textStyle,
          ),
          maxLines: 2,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        )..layout(maxWidth: constraints.maxWidth);

        final shouldShowMore = textPainter.didExceedMaxLines;

        if (!shouldShowMore) {
          return Text(
            text,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          );
        }

        return SizedBox(
          height: 43,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Text(
                  text,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.only(
                      right: 22,
                      top: 2,
                      bottom: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppColors.cardBackground.withValues(alpha: 0.0),
                          AppColors.cardBackground.withValues(alpha: 1),
                          AppColors.cardBackground,
                        ],
                      ),
                    ),
                    child: Text(
                      'عرض المزيد',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 212,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.hint,
        size: 44,
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _badgeColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
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
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: AppColors.yellow,
            size: 17,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}