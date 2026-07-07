import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/journal/journal_models.dart';
import 'journal_card.dart';
import 'journal_ui_helpers.dart';
import 'skill_progress_item.dart';

class PerformanceActivityCard extends StatelessWidget {
  final PerformanceModel performance;

  const PerformanceActivityCard({
    super.key,
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _PerformanceMetric(
        label: 'نسبة الإتمام',
        value: performance.completionScore,
        color: AppColors.primary,
      ),
      _PerformanceMetric(
        label: 'المثابرة',
        value: performance.persistenceScore,
        color: AppColors.pink,
      ),
      _PerformanceMetric(
        label: 'الكفاءة',
        value: performance.efficiencyScore,
        color: AppColors.secondary,
      ),
      _PerformanceMetric(
        label: 'الاستقلالية',
        value: performance.independenceScore,
        color: AppColors.yellow,
      ),
      _PerformanceMetric(
        label: 'الاستراتيجية',
        value: performance.strategyScore,
        color: AppColors.primary,
      ),
    ];

    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.border,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نشاط رقم ${performance.activityId}',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
                (item) => SkillProgressItem(
              name: item.label,
              value: normalizeScore(item.value),
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceMetric {
  final String label;
  final double value;
  final Color color;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.color,
  });
}