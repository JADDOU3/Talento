import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RoadmapHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const RoadmapHeader({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoadmapCircleButton(
          icon: Icons.arrow_forward_ios_rounded,
          onTap: onBack,
          flipIcon: true,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'رحلة التعلّم',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'اتبع المسار واكتشف الأنشطة خطوة بخطوة',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.68),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 2.5,
                ),
              ),
            ],
          ),
        ),
        RoadmapCircleButton(
          icon: Icons.refresh_rounded,
          onTap: onRefresh,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }
}

class RoadmapCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final bool flipIcon;

  const RoadmapCircleButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
    this.flipIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      icon,
      size: 18,
      color: iconColor,
    );

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.96),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: flipIcon
                ? Transform.scale(
              scaleX: -1,
              child: iconWidget,
            )
                : iconWidget,
          ),
        ),
      ),
    );
  }
}