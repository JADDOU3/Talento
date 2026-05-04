import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';


class AvailableKitsSection extends StatelessWidget {
  const AvailableKitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final kits = [
      {
        'name': 'مستكشف الفضاء',
        'status': 'جديد',
        'icon': Icons.rocket_launch_rounded,
        'color': AppColors.primary,
        'bg': AppColors.primary,
      },
      {
        'name': 'اكتشاف الطبيعة',
        'status': '8 أنشطة متبقية',
        'icon': Icons.eco_rounded,
        'color': AppColors.secondary,
        'bg': AppColors.secondary,
      },
      {
        'name': 'الفنون الإبداعية',
        'status': 'قيد البدء',
        'icon': Icons.palette_rounded,
        'color': AppColors.pink,
        'bg': AppColors.pink,
      },
      {
        'name': 'مملكة الحيوان',
        'status': 'مكتمل 50%',
        'icon': Icons.pets_rounded,
        'color': AppColors.yellow,
        'bg': AppColors.yellow,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحقائب النشطة',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: kits.length,
          itemBuilder: (context, i) => _buildKitCard(kits[i]),
        ),
      ],
    );
  }

  Widget _buildKitCard(Map<String, dynamic> kit) {
    final color = kit['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(kit['icon'] as IconData, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kit['name'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  kit['status'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}