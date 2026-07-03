import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/journal/journal_models.dart';
import 'journal_card.dart';
import 'journal_ui_helpers.dart';
import 'skill_progress_item.dart';

class AchievementRateCard extends StatelessWidget {
  final AIReportModel report;

  const AchievementRateCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final value = normalizeScore(report.analysisConfidence);
    final percent = (value * 100).round();
    final trend = trendInfo(report.focusTrend);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.95),
            AppColors.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
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
              child: const Icon(
                Icons.track_changes_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(
                  '$percent%',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'معدل الإنجاز العام',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: trend.color.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    trend.label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MindsetScoresCard extends StatelessWidget {
  final List<MindsetScoreModel> scores;

  const MindsetScoresCard({
    super.key,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.pink,
      AppColors.secondary,
      AppColors.yellow,
    ];

    return JournalCard(
      color: const Color(0xFFFFF3F6),
      borderColor: AppColors.pink.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('بطاقة أداء المهارات'),
          const SizedBox(height: 4),
          Text(
            'بناء على أدائك الأسبوعي',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 18),
          ...scores.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final score = entry.value;

              return SkillProgressItem(
                name: mindsetArabicName(score.mindsetName),
                value: normalizeScore(score.score),
                color: colors[index % colors.length],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AhaMomentsCard extends StatelessWidget {
  final AIReportModel report;

  const AhaMomentsCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _AhaMomentText(
        icon: Icons.push_pin_rounded,
        color: AppColors.primary,
        text: report.summary,
      ),
      _AhaMomentText(
        icon: Icons.psychology_alt_rounded,
        color: AppColors.pink,
        text: report.learningBehaviorPattern,
      ),
      _AhaMomentText(
        icon: Icons.visibility_rounded,
        color: AppColors.secondary,
        text: report.recommendedFutureObservation,
      ),
    ].where((item) => item.text.trim().isNotEmpty).toList();

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
              _sectionTitle('لحظات "Aha!" ✨'),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'سيتم عرض لحظات التعلّم هنا قريباً',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            )
          else
            ...items.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 12,
                  ),
                  child: _buildAhaTextItem(
                    icon: item.icon,
                    color: item.color,
                    text: item.text,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAhaTextItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class NoReportBanner extends StatelessWidget {
  const NoReportBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return JournalCard(
      color: const Color(0xFFEFFFFB),
      borderColor: AppColors.primary.withValues(alpha: 0.10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🌱',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد تقرير متاح بعد',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'العب بعض الأنشطة وسنقوم بإنشاء تقريرك قريباً',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionTitle(String text) {
  return Text(
    text,
    style: AppTextStyles.bodyLarge.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w900,
      color: AppColors.textPrimary,
    ),
  );
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

class _AhaMomentText {
  final IconData icon;
  final Color color;
  final String text;

  const _AhaMomentText({
    required this.icon,
    required this.color,
    required this.text,
  });
}