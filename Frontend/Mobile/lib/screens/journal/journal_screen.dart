import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/app_background.dart';

import 'widgets/insight_item.dart';
import 'widgets/journal_card.dart';
import 'widgets/skill_progress_item.dart';
import 'widgets/stat_card.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch child mode — if active, show blocked message instead of redirecting
    final childModeState = context.watch<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(),
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                // In child mode: show blocked page message
                child: isChildMode
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded,
                          size: 64,
                          color: AppColors.hint.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'هذه الصفحة غير متاحة في وضع الطفل',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
                    : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildPerformanceCard(),
                      const SizedBox(height: 18),
                      _buildWeeklyInsights(),
                      const SizedBox(height: 18),
                      _buildAchievementCard(),
                      const SizedBox(height: 18),
                      _buildAhaCard(),
                      const SizedBox(height: 14),
                      _buildStatsSection(),
                    ],
                  ),
                ),
              ),
              const BottomNavBar(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اليوميات',
            style: AppTextStyles.headlineLarge
                .copyWith(fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.yellow.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24),
            border:
            Border.all(color: AppColors.yellow.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.yellow, size: 22),
              const SizedBox(width: 6),
              Text('الأسبوع الحالي',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceCard() {
    final items = [
      _SkillProgress('البنّاء', 0.78, AppColors.primary),
      _SkillProgress('العالم', 0.64, AppColors.pink),
      _SkillProgress('المستكشف', 0.82, AppColors.secondary),
      _SkillProgress('المخترع', 0.55, AppColors.yellow),
    ];
    return JournalCard(
      color: const Color(0xFFFFF3F6),
      borderColor: AppColors.pink.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('بطاقة أداء المهارات'),
          const SizedBox(height: 4),
          Text('بناء على أدائك الأسبوعي',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
          const SizedBox(height: 18),
          ...items.map((item) => SkillProgressItem(
              name: item.name, value: item.value, color: item.color)),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('استكشافاتك الأسبوعية'),
        const SizedBox(height: 10),
        JournalCard(
          color: const Color(0xFFEFFFFB),
          borderColor: AppColors.primary.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 110,
            child: Align(
              alignment: Alignment.topRight,
              child: Text(
                'سيتم عرض استكشافاتك الأسبوعية هنا قريباً',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontSize: 12, color: AppColors.hint),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.track_changes_rounded,
                  color: AppColors.white, size: 24),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text('84%',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('معدل الإنجاز العام',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('تحسن عن الأسبوع الماضي +12%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAhaCard() {
    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(Icons.auto_awesome_rounded, AppColors.pink),
              const SizedBox(width: 10),
              _sectionTitle('لحظات "Aha!"'),
            ],
          ),
          const SizedBox(height: 14),
          const InsightItem(
            icon: Icons.psychology_alt_rounded,
            color: AppColors.primary,
            title: 'اكتشفت نمط الطفل الهندسي',
            description:
            'لاحظنا اهتماماً واضحاً بالتجارب التي تعتمد على التركيب والبناء وحل المشكلات.',
          ),
          const SizedBox(height: 12),
          const InsightItem(
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.pink,
            title: 'قفزة إبداعية جديدة',
            description:
            'بدأ الطفل يقترح حلولاً خاصة به بدل اتباع الخطوات فقط.',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return const Column(
      children: [
        StatCard(
          icon: Icons.lightbulb_outline_rounded,
          iconColor: AppColors.primary,
          background: Color(0xFFEFFFFB),
          title: 'المعدل اليومي',
          description: 'متوسط التفاعل اليومي: 10 - 15 دقيقة.',
        ),
        SizedBox(height: 12),
        StatCard(
          icon: Icons.travel_explore_rounded,
          iconColor: AppColors.pink,
          background: Color(0xFFFFF3F6),
          title: 'نسبة الاستكشاف',
          description: 'اهتمام واضح بالتجارب الجديدة والأنشطة المتنوعة.',
        ),
        SizedBox(height: 12),
        StatCard(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.secondary,
          background: Color(0xFFEFFFFB),
          title: 'معدل الاستقلالية',
          description: 'قدرة أفضل على تنفيذ الخطوات بدون مساعدة مباشرة.',
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary));
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}

class _SkillProgress {
  final String name;
  final double value;
  final Color color;
  const _SkillProgress(this.name, this.value, this.color);
}
