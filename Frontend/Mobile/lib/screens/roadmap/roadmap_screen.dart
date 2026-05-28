import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/app_background.dart';

class RoadmapScreen extends StatelessWidget {
  final int kitId;
  final int childId;

  const RoadmapScreen({
    super.key,
    required this.kitId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'رحلة التعلّم',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 38),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.route_rounded,
                          color: AppColors.primary,
                          size: 52,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Roadmap Screen',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'kitId: $kitId\nchildId: $childId',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}