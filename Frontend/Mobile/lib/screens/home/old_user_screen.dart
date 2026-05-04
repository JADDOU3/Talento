import 'package:flutter/material.dart';
import 'package:mobile/screens/home/widgets/current_kit_card.dart';
import 'package:mobile/screens/home/widgets/daily_challenge_card.dart';
import 'package:mobile/screens/home/widgets/progression_card.dart';
import 'package:mobile/screens/home/widgets/quick_actions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/bottom_nav_bar.dart';



class OldUserScreen extends StatelessWidget {
  const OldUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Welcome Title
                    Text(
                      'هل انت مستعد لاكتشاف اليوم ؟',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Progression Card
                    const ProgressionCard(
                      level: 'المستوى 1',
                      kitName: 'المتدرب الفضولي',
                      progress: 0.4,
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const QuickActions(),
                    const SizedBox(height: 24),

                    // Daily Challenge
                    const DailyChallengeCard(
                      challenge: 'ارسم 3 خرائط للمجموعات النجمية',
                    ),
                    const SizedBox(height: 24),

                    // Current Kit Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'حقيبتك الحالية',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'عرض الكل',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Current Kit Card
                    const CurrentKitCard(
                      kitTitle: 'مستكشف الفضاء',
                      progressText: 'تم انجاز 4 من اصل 10 مهام',
                      imagePath: 'assets/images/kit1.png',
                      progress: 0.4,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Nav Bar
            const BottomNavBar(selectedIndex: 2),
          ],
        ),
      ),
    );
  }
}