import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/journal/journal_models.dart';
import 'journal_card.dart';
import 'journal_ui_helpers.dart';

class AchievementRateCard extends StatelessWidget {
  final JournalActivitiesProgressModel activitiesProgress;

  const AchievementRateCard({
    super.key,
    required this.activitiesProgress,
  });

  @override
  Widget build(BuildContext context) {
    final value = activitiesProgress.progress;
    final percent = (value * 100).round();

    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 82,
            height: 82,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.001),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(68, 68),
                  painter: _AchievementRingPainter(progress: value),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$percent%',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'معدل الانجاز العام',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 10.8,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementRingPainter extends CustomPainter {
  final double progress;

  const _AchievementRingPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
    final strokeWidth = 7.0;
    final rect = Offset.zero & size;
    final circleRect = rect.deflate(strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.primary.withValues(alpha: 0.92),
        ],
        stops: const [0.0, 0.55, 1.0],
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
      ).createShader(circleRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      circleRect,
      -math.pi / 2,
      math.pi * 2,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      circleRect,
      -math.pi / 2,
      math.pi * 2 * clampedProgress,
      false,
      progressPaint,
    );

    if (clampedProgress > 0) {
      final endAngle = -math.pi / 2 + (math.pi * 2 * clampedProgress);
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );

      final dotPaint = Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.fill;

      final dotBorderPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 5.2, dotBorderPaint);
      canvas.drawCircle(endPoint, 3.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AchievementRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PendingMindsetScoresCard extends StatelessWidget {
  final int completedActivities;
  final int totalActivities;

  const PendingMindsetScoresCard({
    super.key,
    required this.completedActivities,
    required this.totalActivities,
  });

  @override
  Widget build(BuildContext context) {
    final hasKnownTotal = totalActivities > 0;
    final safeCompleted = hasKnownTotal
        ? completedActivities.clamp(0, totalActivities)
        : 0;
    final progress = hasKnownTotal
        ? (safeCompleted / totalActivities).clamp(0.0, 1.0).toDouble()
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFAFB),
            Color(0xFFFFF7FC),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.pink.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.17),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_graph_rounded,
                    color: AppColors.yellow,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'بطاقة أداء المهارات',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.09),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.10),
                    ),
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                Positioned(
                  top: 2,
                  left: -7,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.pink.withValues(alpha: 0.80),
                    size: 17,
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: -5,
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.yellow.withValues(alpha: 0.90),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'ستظهر مهارات طفلك بعد إكمال الرحلة',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'عندما يُكمل طفلك جميع الألعاب، سنعرض هنا تطوّر مهاراته وأداءه.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Icon(
                        Icons.extension_rounded,
                        color: AppColors.primary.withValues(alpha: 0.85),
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          hasKnownTotal
                              ? '$safeCompleted من أصل $totalActivities لعبة مكتملة'
                              : 'أكملوا رحلة الألعاب لتظهر تفاصيل التقدّم هنا',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (hasKnownTotal)
                        Text(
                          '${(progress * 100).round()}%',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        color: AppColors.primary.withValues(alpha: 0.11),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 8,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFAFB),
            Color(0xFFFFF6FF),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.pink.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pink.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSkillsHeader(),
          const SizedBox(height: 5),
          ...scores.asMap().entries.map(
                (entry) {
              final index = entry.key;
              final score = entry.value;
              final display = _mindsetDisplay(score.mindsetName, index);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == scores.length - 1 ? 0 : 8,
                ),
                child: _PremiumSkillRow(
                  title: mindsetArabicName(score.mindsetName),
                  value: normalizeScore(score.score),
                  color: display.color,
                  icon: display.icon,
                  iconBackground: display.background,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsHeader() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'بطاقة أداء المهارات',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          _decorativeStar(),
        ],
      ),
    );
  }

  Widget _decorativeStar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.yellow.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              '⭐',
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
        Positioned(
          top: -3,
          left: -4,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.pink.withValues(alpha: 0.75),
            size: 13,
          ),
        ),
      ],
    );
  }

}

class _PremiumSkillRow extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final Color iconBackground;
  final IconData icon;

  const _PremiumSkillRow({
    required this.title,
    required this.value,
    required this.color,
    required this.iconBackground,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                _skillIcon(),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$percent%',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _FancyProgressBar(
            value: value,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _skillIcon() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: iconBackground,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 16,
      ),
    );
  }
}

class _FancyProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _FancyProgressBar({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedValue = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: normalizedValue,
              alignment: Alignment.centerRight,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.78),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_MindsetDisplay _mindsetDisplay(String name, int index) {
  final normalizedName = name.trim();

  switch (normalizedName) {
    case 'Cognitive':
      return const _MindsetDisplay(
        color: AppColors.primary,
        background: Color(0xFFEAF8F5),
        icon: Icons.psychology_alt_rounded,
      );
    case 'Social-Emotional':
      return const _MindsetDisplay(
        color: AppColors.pink,
        background: Color(0xFFFFEEF3),
        icon: Icons.favorite_border_rounded,
      );
    case 'Sensory-Kinesthetic':
      return const _MindsetDisplay(
        color: AppColors.secondary,
        background: Color(0xFFEDF9FC),
        icon: Icons.directions_run_rounded,
      );
    case 'Creative-Visual':
      return const _MindsetDisplay(
        color: AppColors.yellow,
        background: Color(0xFFFFF7DE),
        icon: Icons.palette_outlined,
      );
    default:
      final fallback = [
        const _MindsetDisplay(
          color: AppColors.primary,
          background: Color(0xFFEAF8F5),
          icon: Icons.psychology_alt_rounded,
        ),
        const _MindsetDisplay(
          color: AppColors.pink,
          background: Color(0xFFFFEEF3),
          icon: Icons.favorite_border_rounded,
        ),
        const _MindsetDisplay(
          color: AppColors.secondary,
          background: Color(0xFFEDF9FC),
          icon: Icons.directions_run_rounded,
        ),
        const _MindsetDisplay(
          color: AppColors.yellow,
          background: Color(0xFFFFF7DE),
          icon: Icons.palette_outlined,
        ),
      ];

      return fallback[index % fallback.length];
  }
}

class _MindsetDisplay {
  final Color color;
  final Color background;
  final IconData icon;

  const _MindsetDisplay({
    required this.color,
    required this.background,
    required this.icon,
  });
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
        color: AppColors.primary,
        text: report.summary,
      ),
      _AhaMomentText(
        color: AppColors.pink,
        text: report.learningBehaviorPattern,
      ),
      _AhaMomentText(
        color: AppColors.secondary,
        text: report.recommendedFutureObservation,
      ),
    ].where((item) => item.text.trim().isNotEmpty).toList();

    return JournalCard(
      color: AppColors.cardBackground,
      borderColor: AppColors.primary.withValues(alpha: 0.06),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAhaHeader(),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'سيتم عرض الرؤى هنا قريباً',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...items.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final item = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == items.length - 1 ? 0 : 10,
                  ),
                  child: _AhaInsightTile(
                    index: index + 1,
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

  Widget _buildAhaHeader() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.pink.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.pink,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'رؤى حول أداء الطفل ✨',
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
}

class _AhaInsightTile extends StatelessWidget {
  final int index;
  final Color color;
  final String text;

  const _AhaInsightTile({
    required this.index,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _numberBadge(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberBadge() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Center(
        child: Text(
          '$index',
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AhaMomentText {
  final Color color;
  final String text;

  const _AhaMomentText({
    required this.color,
    required this.text,
  });
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


