import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selectedColor ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : AppColors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : AppColors.border.withValues(alpha: 0.75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.20)
                    : AppColors.black.withValues(alpha: 0.025),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}