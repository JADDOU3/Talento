import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_model.dart';


class AvailableKitsSection extends StatelessWidget {
  final List<KitModel>? kits;

  const AvailableKitsSection({super.key, this.kits});

  @override
  Widget build(BuildContext context) {
    final hasRealKits = kits != null && kits!.isNotEmpty;

    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.pink,
      AppColors.yellow,
    ];

    final icons = [
      Icons.rocket_launch_rounded,
      Icons.eco_rounded,
      Icons.palette_rounded,
      Icons.pets_rounded,
    ];

    final mockKits = [
      {'name': 'مستكشف الفضاء', 'status': 'جديد'},
      {'name': 'اكتشاف الطبيعة', 'status': '8 أنشطة متبقية'},
      {'name': 'الفنون الإبداعية', 'status': 'قيد البدء'},
      {'name': 'مملكة الحيوان', 'status': 'مكتمل 50%'},
    ];

    final itemCount = hasRealKits ? kits!.length : mockKits.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

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
          itemCount: itemCount,
          itemBuilder: (context, i) {
            final color = colors[i % colors.length];
            final icon = icons[i % icons.length];

            if (hasRealKits) {
              final kit = kits![i];
              return _buildKitCard(
                name: kit.name,
                status: kit.type.isNotEmpty ? kit.type : 'نشط',
                color: color,
                icon: icon,
              );
            } else {
              return _buildKitCard(
                name: mockKits[i]['name']!,
                status: mockKits[i]['status']!,
                color: color,
                icon: icon,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildKitCard({
    required String name,
    required String status,
    required Color color,
    required IconData icon,
  }) {
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
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
                  status,
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