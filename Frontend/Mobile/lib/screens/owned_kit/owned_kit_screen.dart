import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/widgets/app_background.dart';

import 'widgets/primary_button.dart';
import 'widgets/secondary_button.dart';
import 'widgets/journey_step_item.dart';
import 'widgets/learning_card.dart';
import 'widgets/section_title.dart';

class OwnedKitScreen extends StatelessWidget {
  const OwnedKitScreen({super.key});

  static const String kitTitle = 'حقيبة مستكشف الفضاء';
  static const String kitBadge = 'حقيبة مبتدئ';
  static const String kitDescription =
      'انطلق في رحلة عبر النجوم لاكتشاف أسرار الفلك والمجرات';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 6, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _KitHeader(),
                      const SizedBox(height: 22),
                      const _MainKitImage(),
                      const SizedBox(height: 26),
                      const _JourneyProgressSection(),
                      const SizedBox(height: 24),
                      const _LearningPathSection(),
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
}


class _KitHeader extends StatelessWidget {
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pink.withOpacity(0.16),
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
            OwnedKitScreen.kitTitle,
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.primary,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: 330,
            child: Text(
              OwnedKitScreen.kitDescription,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.75,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: const [
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

class _MainKitImage extends StatelessWidget {
  const _MainKitImage();

  @override
  Widget build(BuildContext context) {
    final double size = MediaQuery.sizeOf(context).width.clamp(0, 390) * 0.66;

    return Center(
      child: Transform.rotate(
        angle: -0.075,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.16),
                blurRadius: 24,
                spreadRadius: 1,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?auto=format&fit=crop&w=900&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.inputFill,
              alignment: Alignment.center,
              child: Icon(
                Icons.rocket_launch_rounded,
                size: 72,
                color: AppColors.primary.withOpacity(0.55),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JourneyProgressSection extends StatelessWidget {
  const _JourneyProgressSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      JourneyStepData(
        label: 'مكتمل',
        status: JourneyStepStatus.completed,
        icon: Icons.check_rounded,
      ),
      JourneyStepData(
        label: 'مكتمل',
        status: JourneyStepStatus.completed,
        icon: Icons.check_rounded,
      ),
      JourneyStepData(
        label: 'الحالي',
        status: JourneyStepStatus.current,
        icon: Icons.rocket_launch_rounded,
      ),
      JourneyStepData(
        label: 'قادم',
        status: JourneyStepStatus.upcoming,
        icon: Icons.flag_rounded,
      ),
      JourneyStepData(
        label: 'مقفل',
        status: JourneyStepStatus.locked,
        icon: Icons.lock_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'خريطة الرحلة الحالية'),
          const SizedBox(height: 16),
          SizedBox(
            height: 82,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      left: 30,
                      right: 30,
                      top: 22,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 30,
                      top: 22,
                      width: (constraints.maxWidth - 60) * 0.50,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.78),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: steps
                          .map(
                            (step) => JourneyStepItem(
                              label: step.label,
                              status: step.status,
                              icon: step.icon,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LearningPathSection extends StatelessWidget {
  const _LearningPathSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'مسار التعلم'),
        SizedBox(height: 14),
        LearningCard(
          title: 'بناء الصاروخ',
          subtitle: 'ابدأ في بناء مشروعك الأول',
          icon: Icons.rocket_launch_rounded,
          type: LearningCardType.active,
        ),
        SizedBox(height: 16),
        LearningCard(
          title: 'مهمة التحدي',
          subtitle: 'تحدى نفسك في بناء نموذج مبسط للمركبة الفضائية',
          icon: Icons.stars_rounded,
          type: LearningCardType.challenge,
          buttonText: 'ابدأ الآن',
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

class JourneyStepData {
  final String label;
  final JourneyStepStatus status;
  final IconData icon;

  const JourneyStepData({
    required this.label,
    required this.status,
    required this.icon,
  });
}
