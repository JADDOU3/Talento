import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/home/home_cubit.dart';
import '../../cubits/home/home_data.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../kit_library/kit_library_screen.dart';
import '../owned_kit/owned_kit_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/current_kit_card.dart';
import 'widgets/daily_challenge_card.dart';
import 'widgets/progression_card.dart';

class OldUserScreen extends StatelessWidget {
  final HomeData data;

  const OldUserScreen({
    super.key,
    required this.data,
  });

  void _goToKitsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KitLibraryScreen(),
      ),
    );
  }

  void _goToOwnedKit(BuildContext context) {
    final kit = data.lastUsedKit;
    final childId = data.selectedChild?.id;

    if (kit == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OwnedKitScreen(
          kit: kit,
          childId: childId,
        ),
      ),
    );
  }

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childName = data.selectedChild?.name ?? '';
    final kit = data.lastUsedKit;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(),
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
                      _buildHeader(childName),
                      const SizedBox(height: 18),
                      if (!data.hasSelectedChild) ...[
                        _buildNoSelectedChildCard(context),
                      ] else ...[
                        if (data.hasLastReachedActivity) ...[
                          ProgressionCard(
                            level:
                            data.lastReachedActivity?.activityName ?? '',
                            kitName:
                            'المستوى ${data.lastReachedActivity?.currentLevelNumber ?? data.currentLevel}',
                            progress: data.progress,
                            progressLabel: data.progressLabel,
                            showProgressBar: data.totalActivitiesCount > 0,
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (data.hasDailyChallenge) ...[
                          DailyChallengeCard(
                            challenge: data.dailyChallenge!,
                            challengeAnswered: data.challengeAnswered,
                            challengeCorrect: data.challengeCorrect,
                            correctAnswer: data.correctAnswer,
                            isSubmitting:
                            data.isSubmittingChallengeAnswer,
                            submittingAnswer: data.submittingAnswer,
                            onAnswerSelected: (answer) {
                              context
                                  .read<HomeCubit>()
                                  .submitChallengeAnswer(
                                data.dailyChallenge!.id,
                                answer,
                              );
                            },
                          ),
                          const SizedBox(height: 22),
                        ],
                        _buildCurrentKitSection(context),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
              const BottomNavBar(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String childName) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        childName.isEmpty
            ? 'هل أنت مستعد للاكتشاف اليوم؟'
            : 'هل $childName مستعد للاكتشاف اليوم؟',
        textAlign: TextAlign.right,
        style: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.textPrimary,
          height: 1.35,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildCurrentKitSection(BuildContext context) {
    final kit = data.lastUsedKit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'صندوقك الحالي',
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        if (data.hasLastUsedKit)
          CurrentKitCard(
            kitTitle: kit?.name ?? 'الصندوق الحالي',
            progressText: data.progressLabel,
            imagePath: kit?.imageUrl ?? '',
            progress: data.progress,
            showProgressBar: data.totalActivitiesCount > 0,
            onContinue: () => _goToOwnedKit(context),
          )
        else
          _buildStartFirstKitCard(context),
      ],
    );
  }

  Widget _buildNoSelectedChildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.child_care_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'لا يوجد طفل محدد حاليًا',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختاري طفلًا أو أضيفي بيانات طفل جديد حتى تظهر بيانات الصفحة الرئيسية.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _goToProfile(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('إدارة الأطفال'),
          ),
        ],
      ),
    );
  }

  Widget _buildStartFirstKitCard(BuildContext context) {
    final childName = data.selectedChild?.name ?? 'الطفل';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.extension_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ابدأ أول صندوق تعليمي',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'لا توجد جلسات بعد لـ $childName. اختاري أول صندوق حتى يظهر التقدم هنا.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _goToKitsList(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'استكشاف الصناديق',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}