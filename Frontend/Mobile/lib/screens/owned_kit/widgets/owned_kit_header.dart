import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OwnedKitHeader extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final VoidCallback onResume;

  const OwnedKitHeader({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = description.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.white.withOpacity(0.95),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.055),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _KitCoverImage(imageUrl: imageUrl),

            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.88),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.primary,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),

                      if (hasDescription) ...[
                        const SizedBox(height: 9),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            description,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      _ResumeButton(onTap: onResume),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KitCoverImage extends StatelessWidget {
  final String imageUrl;

  const _KitCoverImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: AppColors.white.withOpacity(0.88),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imageUrl.trim().isEmpty
            ? const _ImagePlaceholder()
            : Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
        ),
      ),
    );
  }
}


class _ResumeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ResumeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 44,
        width: 185,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.88),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.24),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.rtl,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    'أكمل الرحلة',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

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
            AppColors.primary.withOpacity(0.10),
            AppColors.secondary.withOpacity(0.10),
          ],
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/kit_placeholder.png',
          width: 78,
          height: 78,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.88),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.primary,
                size: 34,
              ),
            );
          },
        ),
      ),
    );
  }
}