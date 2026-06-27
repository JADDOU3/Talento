import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProgressionCard extends StatelessWidget {
  final String level;
  final String kitName;
  final double progress;
  final String? progressLabel;
  final bool showProgressBar;

  const ProgressionCard({
    super.key,
    required this.level,
    required this.kitName,
    required this.progress,
    this.progressLabel,
    this.showProgressBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    kitName,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  if (showProgressBar) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: safeProgress,
                        backgroundColor:
                        AppColors.white.withValues(alpha: 0.28),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                        minHeight: 9,
                      ),
                    ),
                    if (progressLabel != null &&
                        progressLabel!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        progressLabel!,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.22),
                ),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppColors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}