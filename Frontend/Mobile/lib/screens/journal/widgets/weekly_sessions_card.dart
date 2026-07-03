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
            height: 150,
            child: allEmpty
                ? Align(
              alignment: Alignment.topRight,
              child: Text(
                'سيتم عرض استكشافاتك الأسبوعية هنا قريباً',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.hint,
                ),
              ),
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days
                  .map(
                    (day) => Expanded(
                  child: _buildWeeklyBar(
                    label: day.label,
                    count: day.count,
                    maxCount: maxCount,
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyBar({
    required String label,
    required int count,
    required int maxCount,
  }) {
    final fillPercent = maxCount == 0 ? 0.0 : count / maxCount;
    final barHeight = 86.0 * fillPercent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$count',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 18,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 18,
                    height: count == 0 ? 0 : barHeight.clamp(8.0, 86.0),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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