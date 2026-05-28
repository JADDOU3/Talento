import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/app_background.dart';
import '../roadmap/roadmap_screen.dart';

import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';

class OwnedKitScreen extends StatelessWidget {
  final dynamic kit;
  final int? childId;

  const OwnedKitScreen({
    super.key,
    required this.kit,
    this.childId,
  });

  static const String kitBadge = 'حقيبة مبتدئ';

  int? get _kitId {
    final id = kit.id;

    if (id is int) return id;
    return int.tryParse(id.toString());
  }

  void _openRoadmap(BuildContext context) {
    final kitId = _kitId;

    if (kitId == null) {
      _showSnackBar(
        context,
        'لا يمكن فتح خارطة الرحلة لأن رقم الحقيبة غير متوفر',
      );
      return;
    }

    if (childId == null) {
      _showSnackBar(
        context,
        'اختاري طفلًا أولًا حتى تظهر رحلة التعلّم',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoadmapScreen(
          kitId: kitId,
          childId: childId!,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Column(
            children: [
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
                      _RoadmapEntryCard(
                        onTap: () => _openRoadmap(context),
                      ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
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

class _RoadmapEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _RoadmapEntryCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.route_rounded,
                color: AppColors.primary,
                size: 31,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رحلة التعلّم',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'شاهدي مسار الأنشطة والإنجازات داخل هذه الحقيبة',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}