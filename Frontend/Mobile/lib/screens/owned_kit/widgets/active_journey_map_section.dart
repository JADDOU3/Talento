import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';
import 'journey_step_item.dart';

typedef JourneyCurrentActivityTap = void Function(
    RoadmapActivityModel activity,
    int activityIndex,
    );

class ActiveJourneyMapSection extends StatelessWidget {
  final List<RoadmapActivityModel> activities;
  final JourneyCurrentActivityTap onCurrentActivityTap;

  const ActiveJourneyMapSection({
    super.key,
    required this.activities,
    required this.onCurrentActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    final nodes = _previewNodes(activities);

    if (nodes.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentIndex = nodes.indexWhere((node) => node.activity.isCurrent);
    final activeIndex = currentIndex < 0 ? nodes.length ~/ 2 : currentIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.025),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'خريطة الرحلة النشطة',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            height: 164,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.84),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.07),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final count = nodes.length;

                  return Stack(
                    children: [
                      Positioned(
                        left: -34,
                        top: -18,
                        child: Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: AppColors.pink.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Positioned(
                        right: -36,
                        top: -20,
                        child: Container(
                          width: 122,
                          height: 122,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.11),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Positioned(
                        left: 0,
                        bottom: -22,
                        child: Container(
                          width: 128,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.055),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(70),
                              topRight: Radius.circular(70),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: -24,
                        child: Container(
                          width: 130,
                          height: 66,
                          decoration: BoxDecoration(
                            color: AppColors.pink.withOpacity(0.055),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(70),
                              topRight: Radius.circular(70),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: width * 0.24,
                        top: 24,
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.yellow.withOpacity(0.88),
                          size: 14,
                        ),
                      ),

                      Positioned(
                        right: width * 0.23,
                        top: 27,
                        child: Icon(
                          Icons.star_rounded,
                          color: AppColors.pink.withOpacity(0.70),
                          size: 13,
                        ),
                      ),

                      Positioned.fill(
                        child: CustomPaint(
                          painter: _JourneyDashedPathPainter(
                            count: count,
                            currentIndex: activeIndex,
                          ),
                        ),
                      ),

                      for (int i = 0; i < count; i++)
                        _PositionedStep(
                          width: width,
                          index: i,
                          count: count,
                          currentIndex: activeIndex,
                          child: JourneyStepItem(
                            label: '${nodes[i].levelNumber}',
                            status: _stepStatus(nodes[i].activity),
                            color: _colorForStep(i, nodes[i].activity),
                            onTap: nodes[i].activity.isCurrent
                                ? () => onCurrentActivityTap(
                              nodes[i].activity,
                              nodes[i].activityIndex,
                            )
                                : null,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_JourneyPreviewItem> _previewNodes(
      List<RoadmapActivityModel> activities,
      ) {
    if (activities.length <= 5) {
      return [
        for (int i = 0; i < activities.length; i++)
          _JourneyPreviewItem(
            activity: activities[i],
            levelNumber: i + 1,
            activityIndex: i,
          ),
      ];
    }

    final currentIndex = activities.indexWhere((activity) => activity.isCurrent);
    final centerIndex = currentIndex < 0 ? 0 : currentIndex;

    var start = centerIndex - 2;
    var end = centerIndex + 3;

    if (start < 0) {
      end += -start;
      start = 0;
    }

    if (end > activities.length) {
      start -= end - activities.length;
      end = activities.length;
    }

    start = start.clamp(0, activities.length - 5).toInt();
    end = (start + 5).clamp(0, activities.length).toInt();

    return [
      for (int i = start; i < end; i++)
        _JourneyPreviewItem(
          activity: activities[i],
          levelNumber: i + 1,
          activityIndex: i,
        ),
    ];
  }

  JourneyStepStatus _stepStatus(RoadmapActivityModel activity) {
    if (activity.isCompleted) return JourneyStepStatus.completed;
    if (activity.isCurrent) return JourneyStepStatus.current;
    return JourneyStepStatus.locked;
  }

  Color _colorForStep(int index, RoadmapActivityModel activity) {
    if (activity.isCurrent) return AppColors.primary;

    if (!activity.isCompleted) {
      return AppColors.hint;
    }

    final palette = [
      AppColors.primary,
      AppColors.yellow,
      AppColors.secondary,
      AppColors.pink,
      AppColors.primary,
    ];

    return palette[index % palette.length];
  }
}

class _PositionedStep extends StatelessWidget {
  final double width;
  final int index;
  final int count;
  final int currentIndex;
  final Widget child;

  const _PositionedStep({
    required this.width,
    required this.index,
    required this.count,
    required this.currentIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final x = _journeyNodeX(width, index, count);
    final y = _journeyNodeY(index, currentIndex);
    final isCurrent = index == currentIndex;

    return Positioned(
      left: x - (isCurrent ? 32 : 28),
      top: isCurrent ? y - 45 : y - 32,
      width: isCurrent ? 64 : 56,
      height: isCurrent ? 122 : 104,
      child: child,
    );
  }
}

class _JourneyPreviewItem {
  final RoadmapActivityModel activity;
  final int levelNumber;
  final int activityIndex;

  const _JourneyPreviewItem({
    required this.activity,
    required this.levelNumber,
    required this.activityIndex,
  });
}

double _journeyNodeX(double width, int index, int count) {
  if (count <= 1) return width / 2;

  const sidePadding = 36.0;
  final usableWidth = width - (sidePadding * 2);
  return sidePadding + (usableWidth * (index / (count - 1)));
}

double _journeyNodeY(int index, int currentIndex) {
  if (index == currentIndex) return 76;

  final pattern = <double>[
    88,
    78,
    76,
    78,
    88,
  ];

  return pattern[index % pattern.length];
}

class _JourneyDashedPathPainter extends CustomPainter {
  final int count;
  final int currentIndex;

  const _JourneyDashedPathPainter({
    required this.count,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (count <= 1) return;

    final path = Path();

    for (int i = 0; i < count; i++) {
      final x = _journeyNodeX(size.width, i, count);
      final y = _journeyNodeY(i, currentIndex);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final previousX = _journeyNodeX(size.width, i - 1, count);
        final previousY = _journeyNodeY(i - 1, currentIndex);

        final controlX = (previousX + x) / 2;
        final controlY = (previousY + y) / 2 + (i.isOdd ? 12 : -12);

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    final shadowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.075)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, shadowPaint);

    final pathPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.50)
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    _drawDashedPath(
      canvas: canvas,
      path: path,
      paint: pathPaint,
      dashWidth: 7,
      dashSpace: 6,
    );
  }

  void _drawDashedPath({
    required Canvas canvas,
    required Path path,
    required Paint paint,
    required double dashWidth,
    required double dashSpace,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;

        final extractPath = metric.extractPath(
          distance,
          nextDistance.clamp(0, metric.length),
        );

        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyDashedPathPainter oldDelegate) {
    return oldDelegate.count != count ||
        oldDelegate.currentIndex != currentIndex;
  }
}