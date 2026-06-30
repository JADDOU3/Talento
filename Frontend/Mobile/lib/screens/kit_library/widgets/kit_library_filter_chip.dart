import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class KitLibraryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;
  final Color? selectedTextColor;

  const KitLibraryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: isSelected ? color : AppColors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color:
                  isSelected ? color : AppColors.border.withValues(alpha: 0.75),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? color.withValues(alpha: 0.18)
                    : AppColors.black.withValues(alpha: 0.025),
                blurRadius: isSelected ? 10 : 7,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? (selectedTextColor ?? AppColors.white)
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
