import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SkillTagCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const SkillTagCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 118,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}