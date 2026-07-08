import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_model.dart';

class AvailableKitsSection extends StatelessWidget {
  final List<KitModel> kits;
  final VoidCallback? onAddKitTap;

  const AvailableKitsSection({
    super.key,
    this.kits = const [],
    this.onAddKitTap,
  });

  @override
  Widget build(BuildContext context) {
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

    final itemCount = kits.length + (onAddKitTap == null ? 0 : 1);

    if (itemCount == 0) {
      return Center(
        child: Text(
          'لا توجد حقائب لهذا الطفل',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GridView.builder(
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
        if (onAddKitTap != null && i == kits.length) {
          return _buildAddKitCard();
        }

        final kit = kits[i];
        final color = colors[i % colors.length];
        final icon = icons[i % icons.length];

        return _buildKitCard(
          name: kit.name,
          status: kit.type.isNotEmpty ? kit.type : 'نشط',
          color: color,
          icon: icon,
        );
      },
    );
  }

  Widget _buildAddKitCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onAddKitTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.035),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 30,
              ),
            ),
          ),
        ),
      ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}