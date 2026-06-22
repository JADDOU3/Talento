import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double? width;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 42,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: AppColors.inputFill, // شلت opacity

          foregroundColor: AppColors.textSecondary,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),

          // ✨ padding أحسن
          padding: const EdgeInsets.symmetric(horizontal: 26),

          // ✨ border خفيف يعطي شكل مرتب
          side: BorderSide(
            color: AppColors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13, // أكبر شوي
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}