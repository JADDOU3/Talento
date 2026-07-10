import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class OwnerDeleteMenu extends StatelessWidget {
  final String deleteLabel;
  final VoidCallback onDelete;

  const OwnerDeleteMenu({
    super.key,
    required this.deleteLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.textSecondary,
        size: 22,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.white,
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          value: 'delete',
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  deleteLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.red,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
