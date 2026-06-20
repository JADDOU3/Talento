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
        // 🔥 PLAYFUL TITLE
        // Added a little decorative element if needed,
        // using your primary palette for a pop of color
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading.copyWith(
            fontSize: 40, // Slightly larger for impact
            fontWeight: FontWeight.w900, // Extra bold for a fun feel
            color: AppColors.cartTeal, // Used Teal for a friendly "Kid" pop
          ),
        ),

        const SizedBox(height: 16),

        // 🔥 SUBTITLE (Softer look)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: 600,
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18, // Slightly larger for readability
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500, // Slightly heavier for clarity
            ),
          ),
        ),
      ],
    );
  }
}