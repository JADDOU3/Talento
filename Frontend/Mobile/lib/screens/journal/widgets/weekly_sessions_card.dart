import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/journal/journal_models.dart';
import 'journal_card.dart';
import 'journal_ui_helpers.dart';

class WeeklySessionsCard extends StatelessWidget {
  final List<DailySessionModel> sessions;

  const WeeklySessionsCard({
    super.key,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context) {
    final days = _buildWeeklyChartDays(sessions);
    final allEmpty = days.every((day) => day.count == 0);
    final maxCount = days
        .map((day) => day.count)
        .fold<int>(0, (previous, current) {
      return current > previous ? current : previous;
    });

    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.primary.withValues(alpha: 0.07),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          if (allEmpty)
            _buildEmptyState()
          else ...[
            _buildChart(days, maxCount),
            const SizedBox(height: 12),
            _buildFooterHint(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'استكشافاتك الأسبوعية',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildChart(List<_WeeklyChartDay> days, int maxCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF8FFFE),
            Color(0xFFEFFFFB),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: days.map(
                (day) {
              return Expanded(
                child: _WeeklyDayCard(
                  label: day.label,
                  count: day.count,
                  maxCount: maxCount,
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_rounded,
            color: AppColors.primary.withValues(alpha: 0.45),
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            'سيتم عرض استكشافاتك الأسبوعية هنا قريباً',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary.withValues(alpha: 0.75),
            size: 16,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              'استمرارك في الاستكشاف يصنع فرقاً في رحلة التعلّم والنمو',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyDayCard extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;

  const _WeeklyDayCard({
    required this.label,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final fillPercent = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = count == 0
        ? 0.0
        : (76.0 * fillPercent).clamp(8.0, 76.0).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.035),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            height: 82,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 18,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.055),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.055),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: 18,
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.80),
                          AppColors.primary,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<_WeeklyChartDay> _buildWeeklyChartDays(
    List<DailySessionModel> sessions,
    ) {
  const fallbackDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  if (sessions.isEmpty) {
    return fallbackDays
        .map((label) => _WeeklyChartDay(label: label, count: 0))
        .toList();
  }

  final sortedSessions = [...sessions]
    ..sort((a, b) => a.date.compareTo(b.date));

  final lastSeven = sortedSessions.length > 7
      ? sortedSessions.sublist(sortedSessions.length - 7)
      : sortedSessions;

  final chartDays = <_WeeklyChartDay>[];

  for (var i = 0; i < lastSeven.length; i++) {
    final session = lastSeven[i];
    final label = arabicWeekdayFromDate(session.date);

    chartDays.add(
      _WeeklyChartDay(
        label: label.isEmpty ? fallbackDays[i % fallbackDays.length] : label,
        count: session.count,
      ),
    );
  }

  while (chartDays.length < 7) {
    chartDays.insert(
      0,
      _WeeklyChartDay(
        label: fallbackDays[chartDays.length % fallbackDays.length],
        count: 0,
      ),
    );
  }

  return chartDays;
}

class _WeeklyChartDay {
  final String label;
  final int count;

  const _WeeklyChartDay({
    required this.label,
    required this.count,
  });
}