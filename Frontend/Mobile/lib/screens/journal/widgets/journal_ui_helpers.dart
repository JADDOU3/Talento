import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

double normalizeScore(double score) {
  if (score.isNaN || score.isInfinite) return 0;

  if (score > 1) {
    return (score / 100).clamp(0.0, 1.0).toDouble();
  }

  return score.clamp(0.0, 1.0).toDouble();
}

String mindsetArabicName(String name) {
  const mindsetNameAr = {
    'Cognitive': 'المعرفي',
    'Social-Emotional': 'الاجتماعي العاطفي',
    'Sensory-Kinesthetic': 'الحسي الحركي',
    'Creative-Visual': 'الإبداعي البصري',
  };

  return mindsetNameAr[name.trim()] ?? name;
}

TrendInfo trendInfo(String trend) {
  switch (trend.trim().toLowerCase()) {
    case 'improving':
      return const TrendInfo('تحسن', AppColors.primary);
    case 'declining':
      return const TrendInfo('تراجع', Colors.redAccent);
    case 'stable':
      return const TrendInfo('مستقر', AppColors.hint);
    default:
      return const TrendInfo('مستقر', AppColors.hint);
  }
}

List<String> versionsUpTo(String version) {
  final trimmed = version.trim();

  if (trimmed.isEmpty) return [];

  final number = int.tryParse(trimmed.replaceAll(RegExp(r'[^0-9]'), ''));

  if (number == null || number <= 0) {
    return [trimmed];
  }

  return List.generate(number, (index) => 'v${index + 1}');
}

String arabicWeekdayFromDate(String date) {
  const weekdayAr = {
    1: 'الأحد',
    2: 'الاثنين',
    3: 'الثلاثاء',
    4: 'الأربعاء',
    5: 'الخميس',
    6: 'الجمعة',
    7: 'السبت',
  };

  final parsed = DateTime.tryParse(date);

  if (parsed == null) return '';

  final talentoWeekday =
  parsed.weekday == DateTime.sunday ? 1 : parsed.weekday + 1;

  return weekdayAr[talentoWeekday] ?? '';
}

class TrendInfo {
  final String label;
  final Color color;

  const TrendInfo(this.label, this.color);
}