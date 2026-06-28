import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CurrentKitCard extends StatelessWidget {
  final String kitTitle;
  final String progressText;
  final String imagePath;
  final double progress;
  final bool showProgressBar;
  final VoidCallback? onContinue;

  const CurrentKitCard({
    super.key,
    required this.kitTitle,
    required this.progressText,
    required this.imagePath,
    required this.progress,
    this.showProgressBar = true,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.9),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 255,
                child: _buildImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kitTitle,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.task_alt_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          progressText,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (showProgressBar) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: safeProgress,
                        backgroundColor:
                        AppColors.border.withValues(alpha: 0.8),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _GlowyContinueButton(
                    onPressed: onContinue ?? () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    if (imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.science_rounded,
          color: AppColors.white,
          size: 66,
        ),
      ),
    );
  }
}

class _GlowyContinueButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GlowyContinueButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 23,
                ),
                SizedBox(width: 6),
                Text(
                  'أكمل',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}