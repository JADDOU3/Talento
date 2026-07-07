import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/coins/coins_cubit.dart';
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
                            onAnswerSelected: (answer) async {
                              final wasCorrect = await context
                                  .read<HomeCubit>()
                                  .submitChallengeAnswer(
                                data.dailyChallenge!.id,
                                answer,
                              );

                              if (!context.mounted || !wasCorrect) return;

                              // The answer request has completed successfully,
                              // so request the selected child's complete balance
                              // again. We never add a fixed reward locally.
                              await context
                                  .read<CoinsCubit>()
                                  .refreshCoins();
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
    final displayName = childName.trim().isEmpty ? 'بطلنا' : childName.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: Text(
                  'استكشف عالمك اليوم يا $displayName ✨',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.25,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'كل نشاط يقرّبك خطوة جديدة',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.72),
                    height: 1.35,
                    fontSize: 13.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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
    final childName = data.selectedChild?.name.trim().isNotEmpty == true
        ? data.selectedChild!.name.trim()
        : 'بطلنا';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFAFFFF),
            Color(0xFFF0FFFC),
            Color(0xFFFFFCF4),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFBDEDEA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.80),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: 8,
            left: 16,
            child: _StartKitSparkle(
              color: Color(0xFFF8C64E),
              size: 15,
            ),
          ),
          const Positioned(
            bottom: 18,
            right: 20,
            child: _StartKitSparkle(
              color: Color(0xFF73DCD5),
              size: 13,
            ),
          ),
          Positioned(
            top: -26,
            right: -22,
            child: Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.045),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -28,
            left: -22,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      AppColors.secondary.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.85),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 34,
                      color: AppColors.primary,
                    ),
                    Positioned(
                      top: 14,
                      right: 17,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.yellow.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'صندوقك الأول بانتظارك',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'اختار صندوقًا تعليميًا لـ $childName حتى تبدأ رحلة الاكتشاف ويظهر التقدم هنا.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                  fontSize: 12.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 17),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _goToKitsList(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF44D1D8),
                          Color(0xFF17B7A8),
                        ],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.18),
                          blurRadius: 13,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'استكشاف الصناديق',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _StartKitSparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _StartKitSparkle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      color: color.withValues(alpha: 0.82),
      size: size,
    );
  }
}