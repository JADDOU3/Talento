import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InsideItemTile extends StatelessWidget {
  final String text;

  const InsideItemTile({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}