import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChecklistItemWidget extends StatelessWidget {
  final String text;
  final bool isChecked;
  final VoidCallback onToggle;

  const ChecklistItemWidget({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isChecked ? AppColors.primary : AppColors.border,
            width: isChecked ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Checkbox(
              value: isChecked,
              activeColor: AppColors.primary,
              checkColor: AppColors.white,
              side: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}