import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_enums.dart';

class ChildModeOwnedKitCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String type;
  final double rating;
  final VoidCallback onTap;

  const ChildModeOwnedKitCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = kitTypeArabicLabel(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.96),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChildKitImageArea(
                  imageUrl: imageUrl,
                  rating: rating,
                  typeLabel: typeLabel,
                ),
                _ChildKitCompactInfoArea(
                  name: name,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildKitImageArea extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final String typeLabel;

  const _ChildKitImageArea({
    required this.imageUrl,
    required this.rating,
    required this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
      color: AppColors.white.withValues(alpha: 0.96),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.22),
            width: 2.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.trim().isEmpty
                  ? const _ChildImagePlaceholder()
                  : Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
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
                errorBuilder: (_, __, ___) {
                  return const _ChildImagePlaceholder();
                },
              ),

              Positioned(
                top: 12,
                left: 12,
                child: _RatingBadge(rating: rating),
              ),

              if (typeLabel.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _TypeBadge(label: typeLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
              fontSize: 12,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;

  const _TypeBadge({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primary,
            AppColors.secondary.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ChildKitCompactInfoArea extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _ChildKitCompactInfoArea({
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.white.withValues(alpha: 0.96),
            ),
          ),

          Positioned(
            left: -34,
            top: 18,
            child: Container(
              width: 125,
              height: 125,
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.075),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: -34,
            bottom: -34,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 24,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.yellow.withValues(alpha: 0.85),
              size: 17,
            ),
          ),

          Positioned(
            right: 78,
            top: 58,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.pink.withValues(alpha: 0.55),
              size: 12,
            ),
          ),

          Positioned(
            left: 18,
            right: 18,
            top: 22,
            child: Column(
              children: [
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  'صندوقك جاهز للاستكشاف ✨',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 13),

                _StartExplorationButton(onTap: onTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StartExplorationButton extends StatelessWidget {
  final VoidCallback onTap;

  const _StartExplorationButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: 230,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  AppColors.primary,
                  AppColors.secondary,
                ],
              ),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.60),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'ابدأ الاستكشاف',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildImagePlaceholder extends StatelessWidget {
  const _ChildImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withValues(alpha: 0.10),
            AppColors.secondary.withValues(alpha: 0.10),
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/kit_placeholder.png',
          width: 74,
          height: 74,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.88),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            );
          },
        ),
      ),
    );
  }
}