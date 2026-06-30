import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

class LearningCard extends StatelessWidget {
  final String badge;
  final String title;
  final String levelText;
  final double progress;
  final String buttonText;
  final VoidCallback onPressed;

  const LearningCard({
    super.key,
    required this.badge,
    required this.title,
    required this.levelText,
    required this.progress,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.pink.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: AppColors.pink.withOpacity(0.13),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.pink,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            levelText,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.inputFill,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: buttonText,
            height: 46,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
