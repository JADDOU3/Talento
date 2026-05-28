import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';
import 'roadmap_activity_tile.dart';
import 'roadmap_bonus_chest.dart';
import 'roadmap_connector.dart';

class RoadmapGameBoard extends StatefulWidget {
  final List<RoadmapActivityModel> activities;
  final ValueChanged<RoadmapActivityModel> onActivityTap;
  final String mascotAssetPath;

  const RoadmapGameBoard({
    super.key,
    required this.activities,
    required this.onActivityTap,
    this.mascotAssetPath = 'assets/images/template_mascot.png',
  });

  @override
  State<RoadmapGameBoard> createState() => _RoadmapGameBoardState();
}

class _RoadmapGameBoardState extends State<RoadmapGameBoard> {
  late final ScrollController _scrollController;
  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentActivity();
    });
  }

  @override
  void didUpdateWidget(covariant RoadmapGameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activities != widget.activities) {
      _didAutoScroll = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentActivity();
      });
    }
  }

  void _scrollToCurrentActivity() {
    if (_didAutoScroll || !_scrollController.hasClients) return;

    final currentIndex = widget.activities.indexWhere(
          (activity) => activity.isCurrent,
    );

    if (currentIndex == -1) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      _didAutoScroll = true;
      return;
    }

    final itemHeight = 230.0;
    final reversedIndexFromTop = widget.activities.length - 1 - currentIndex;

    final targetOffset = (reversedIndexFromTop * itemHeight).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
    );

    _didAutoScroll = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const SizedBox(height: 18),
      const RoadmapBonusChest(),
      const SizedBox(height: 10),
    ];

    for (int visualIndex = widget.activities.length - 1;
    visualIndex >= 0;
    visualIndex--) {
      final activity = widget.activities[visualIndex];
      final originalIndex = visualIndex;
      final isRight = originalIndex.isEven;

      children.add(
        RoadmapConnector(
          isActive: !activity.isLocked,
          curveToRight: !isRight,
        ),
      );

      children.add(
        _RoadmapStep(
          isRight: isRight,
          child: RoadmapActivityTile(
            activity: activity,
            index: originalIndex,
            onTap: () => widget.onActivityTap(activity),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 220));

    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: _RoadmapBackgroundDecorations(),
          ),
        ),

        ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(6, 10, 6, 24),
          children: children,
        ),

        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: _TopFogOverlay(),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: _RoadStartGuide(
              mascotAssetPath: widget.mascotAssetPath,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  final bool isRight;
  final Widget child;

  const _RoadmapStep({
    required this.isRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isRight ? Alignment.centerRight : Alignment.centerLeft;

    return SizedBox(
      height: 194,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.only(
            right: isRight ? 10 : 0,
            left: isRight ? 0 : 10,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoadStartGuide extends StatelessWidget {
  final String mascotAssetPath;

  const _RoadStartGuide({
    required this.mascotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -20,
            right: -20,
            bottom: -30,
            child: Container(
              height: 118,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background.withValues(alpha: 1.0),
                    AppColors.background.withValues(alpha: 0.92),
                    AppColors.background.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 4,
            bottom: 14,
            child: Image.asset(
              mascotAssetPath,
              width: 165,
              height: 165,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.primary,
                    size: 60,
                  ),
                );
              },
            ),
          ),

          Positioned(
            left: 132,
            bottom: 110,
            child: Transform.rotate(
              angle: 0.03,
              child: Container(
                width: 154,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.97),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Text(
                  'ابدئي الرحلة من هنا ✨',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.3,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 122,
            bottom: 100,
            child: CustomPaint(
              size: const Size(22, 18),
              painter: _BubbleTailPainter(),
            ),
          ),

          Positioned(
            right: 34,
            bottom: 48,
            child: _MiniDecorationDot(
              color: AppColors.pink.withValues(alpha: 0.55),
              size: 9,
            ),
          ),

          Positioned(
            right: 76,
            bottom: 78,
            child: _MiniDecorationDot(
              color: AppColors.yellow.withValues(alpha: 0.75),
              size: 12,
            ),
          ),

          Positioned(
            right: 120,
            bottom: 40,
            child: _MiniDecorationDot(
              color: AppColors.primary.withValues(alpha: 0.50),
              size: 7,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFogOverlay extends StatelessWidget {
  const _TopFogOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background.withValues(alpha: 0.98),
            AppColors.background.withValues(alpha: 0.76),
            AppColors.background.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

class _MiniDecorationDot extends StatelessWidget {
  final Color color;
  final double size;

  const _MiniDecorationDot({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(
        size.width * 0.60,
        size.height * 0.28,
        size.width,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.78,
        0,
        0,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.97)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return false;
  }
}

class _RoadmapBackgroundDecorations extends StatelessWidget {
  const _RoadmapBackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoadmapDecorationsPainter(),
    );
  }
}

class _RoadmapDecorationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final pinkPaint = Paint()
      ..color = AppColors.pink.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = AppColors.yellow.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.12),
      30,
      tealPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.36),
      34,
      pinkPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.13, size.height * 0.75),
      38,
      yellowPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.94, size.height * 0.88),
      30,
      tealPaint,
    );

    _drawSparkle(
      canvas,
      Offset(size.width * 0.18, size.height * 0.30),
      AppColors.pink,
    );

    _drawSparkle(
      canvas,
      Offset(size.width * 0.82, size.height * 0.13),
      AppColors.yellow,
    );

    _drawSparkle(
      canvas,
      Offset(size.width * 0.76, size.height * 0.62),
      AppColors.primary,
    );

    _drawMiniStar(
      canvas,
      Offset(size.width * 0.26, size.height * 0.92),
      AppColors.yellow,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 5, center.dy),
      Offset(center.dx + 5, center.dy),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy - 5),
      Offset(center.dx, center.dy + 5),
      paint,
    );
  }

  void _drawMiniStar(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - 8)
      ..lineTo(center.dx + 2.4, center.dy - 2.4)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx + 2.4, center.dy + 2.4)
      ..lineTo(center.dx, center.dy + 8)
      ..lineTo(center.dx - 2.4, center.dy + 2.4)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx - 2.4, center.dy - 2.4)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RoadmapDecorationsPainter oldDelegate) {
    return false;
  }
}