import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/widgets/app_background.dart';

import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';

class OwnedKitScreen extends StatelessWidget {
  final dynamic kit;

  const OwnedKitScreen({
    super.key,
    required this.kit,
  });

  static const String kitBadge = 'حقيبة مبتدئ';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Column(
            children: [
              // ✅ Custom header with back button instead of TopBar
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 6, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KitHeader(kit: kit),
                      const SizedBox(height: 22),
                    ],
                  ),
                ),
              ),

              const BottomNavBar(selectedIndex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          // ✅ Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                'تفاصيل الحقيبة',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _KitHeader extends StatelessWidget {
  final dynamic kit;

  const _KitHeader({required this.kit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                OwnedKitScreen.kitBadge,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.pink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            kit.name ?? '',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            kit.description ?? '',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 22),

          const Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'استكمال النشاط',
                  height: 48,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SecondaryButton(
                  text: 'عرض سجل المتابعة',
                  height: 48,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}