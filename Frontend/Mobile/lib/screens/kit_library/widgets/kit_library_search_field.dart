import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class KitLibrarySearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const KitLibrarySearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن صندوق',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon: controller.text.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.hint,
                  ),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(26),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
