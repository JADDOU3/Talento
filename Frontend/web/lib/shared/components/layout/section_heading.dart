import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';
import '../../../util/theme/app_text_styles.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔥 TITLE
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        // 🔥 SUBTITLE
        SizedBox(
          width: 600, // 🔥 نفس الفigma (مش عريض كتير)
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}