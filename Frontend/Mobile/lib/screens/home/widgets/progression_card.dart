import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProgressionCard extends StatelessWidget {
  final String level;
  final String kitName;
  final double progress;
  final String? progressLabel;
  final bool showProgressBar;
  final String mascotAssetPath;

  const ProgressionCard({
    super.key,
    required this.level,
    required this.kitName,
    required this.progress,
    this.progressLabel,
    this.showProgressBar = true,
    this.mascotAssetPath = 'assets/images/mascot_racer.png',
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFAFFFF),
              Color(0xFFF0FFFC),
              Color(0xFFFFFCF5),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFBDEDEA),
            width: 1.25,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: AppColors.white.withValues(alpha: 0.80),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              const Positioned(
                top: 78,
                right: 46,
                child: _DottedJourneyPath(),
              ),
              const Positioned(
                bottom: 26,
                right: 34,
                child: _MiniStar(
                  color: Color(0xFF8BDDD7),
                  size: 13,
                ),
              ),
              Positioned(
                bottom: -28,
                left: -26,
                child: Container(
                  width: 105,
                  height: 105,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.045),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    if (showProgressBar) ...[
                      const SizedBox(height: 17),
                      _RaceTrackWithMascot(
                        progress: safeProgress,
                        mascotAssetPath: mascotAssetPath,
                      ),
                      if (progressLabel != null &&
                          progressLabel!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: _ProgressLabel(text: progressLabel!),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerRight,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                level,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: const Color(0xFF086D66),
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                kitName,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RaceTrackWithMascot extends StatelessWidget {
  final double progress;
  final String mascotAssetPath;

  const _RaceTrackWithMascot({
    required this.progress,
    required this.mascotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    const racerWidth = 82.0;
    const trackHeight = 88.0;

    return SizedBox(
      height: trackHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final travelWidth = (width - racerWidth).clamp(0.0, width);

          // RTL:
          // progress 0 = البداية على اليمين
          // progress 1 = الهدف على اليسار
          final racerLeft = travelWidth * (1 - progress);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 30,
                right: 30,
                top: 42,
                child: CustomPaint(
                  painter: _RaceRoadPainter(progress: progress),
                  child: const SizedBox(height: 20),
                ),
              ),
              const Positioned(
                right: 0,
                top: 31,
                child: _StartMarker(),
              ),
              const Positioned(
                left: 0,
                top: 20,
                child: _GoalStarMarker(),
              ),
              const Positioned(
                right: 3,
                top: 3,
                child: _TrackBubble(
                  text: 'البداية',
                  color: Color(0xFFD9FCF7),
                  textColor: AppColors.primary,
                ),
              ),
              const Positioned(
                left: 3,
                top: 3,
                child: _TrackBubble(
                  text: 'الهدف',
                  color: Color(0xFFFFF1BD),
                  textColor: Color(0xFF8C6500),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 560),
                curve: Curves.easeOutBack,
                left: racerLeft,
                top: 8,
                child: _MascotRacer(
                  assetPath: mascotAssetPath,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MascotRacer extends StatelessWidget {
  final String assetPath;

  const _MascotRacer({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.6, end: 1.6),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: SizedBox(
        width: 82,
        height: 70,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 5,
              right: 5,
              bottom: 2,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.primary,
                      size: 42,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RaceRoadPainter extends CustomPainter {
  final double progress;

  _RaceRoadPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    final basePaint = Paint()
      ..color = const Color(0xFFE1F2F0)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    final donePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF48D7D1),
          Color(0xFF1FB7A9),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      basePaint,
    );

    // RTL progress fill: from right to left.
    canvas.drawLine(
      Offset(size.width, centerY),
      Offset(size.width - (size.width * progress), centerY),
      donePaint,
    );

    final dashPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.90)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    const dashCount = 11;
    for (int i = 1; i < dashCount; i++) {
      final x = (size.width / dashCount) * i;

      canvas.drawLine(
        Offset(x - 4, centerY),
        Offset(x + 5, centerY),
        dashPaint,
      );
    }

    final outlinePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, centerY - 10),
      Offset(size.width, centerY - 10),
      outlinePaint,
    );

    canvas.drawLine(
      Offset(0, centerY + 10),
      Offset(size.width, centerY + 10),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RaceRoadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StartMarker extends StatelessWidget {
  const _StartMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: const Color(0xFFE1FBF7),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFBDEDEA),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.star_rounded,
              size: 12,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalStarMarker extends StatelessWidget {
  const _GoalStarMarker();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 61,
      height: 61,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StarRaysPainter(),
            ),
          ),
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFFFE39C),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFC928),
              size: 37,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackBubble extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _TrackBubble({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          height: 1,
        ),
      ),
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  final String text;

  const _ProgressLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cleanedText = text
        .replaceAll('من اصل', 'من')
        .replaceAll('من أصل', 'من')
        .replaceAll('أنشطة', 'نشاط')
        .trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD7F2EF),
        ),
      ),
      child: Text(
        cleanedText,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 13.5,
          height: 1.2,
        ),
      ),
    );
  }
}


class _DottedJourneyPath extends StatelessWidget {
  const _DottedJourneyPath();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.32,
      child: SizedBox(
        width: 142,
        height: 66,
        child: CustomPaint(
          painter: _DottedPathPainter(),
        ),
      ),
    );
  }
}

class _MiniStar extends StatelessWidget {
  final Color color;
  final double size;

  const _MiniStar({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star_rounded,
      color: color,
      size: size,
    );
  }
}

class _StarRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = AppColors.yellow.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 10; i++) {
      final angle = (math.pi * 2 / 10) * i;
      final start = Offset(
        center.dx + math.cos(angle) * 31,
        center.dy + math.sin(angle) * 31,
      );
      final end = Offset(
        center.dx + math.cos(angle) * 40,
        center.dy + math.sin(angle) * 40,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarRaysPainter oldDelegate) => false;
}

class _DottedPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64D8D0)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.10,
        size.width * 0.55,
        size.height * 1.0,
        size.width,
        size.height * 0.35,
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 2.1, paint);
        }
        distance += 12;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPathPainter oldDelegate) => false;
}