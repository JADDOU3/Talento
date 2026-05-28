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

    final itemHeight = 214.0;
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
      const SizedBox(height: 14),
      const RoadmapBonusChest(),
      const SizedBox(height: 8),
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
        _DecoratedRoadmapStep(
          isRight: isRight,
          isCurrent: activity.isCurrent,
          mascotAssetPath: widget.mascotAssetPath,
          child: RoadmapActivityTile(
            activity: activity,
            index: originalIndex,
            onTap: () => widget.onActivityTap(activity),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 46));

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
      ],
    );
  }
}

class _DecoratedRoadmapStep extends StatelessWidget {
  final bool isRight;
  final bool isCurrent;
  final String mascotAssetPath;
  final Widget child;

  const _DecoratedRoadmapStep({
    required this.isRight,
    required this.isCurrent,
    required this.mascotAssetPath,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isRight ? Alignment.centerRight : Alignment.centerLeft;

    return SizedBox(
      height: isCurrent ? 244 : 174,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: alignment,
            child: Padding(
              padding: EdgeInsets.only(
                right: isRight ? 10 : 0,
                left: isRight ? 0 : 10,
                top: isCurrent ? 42 : 0,
              ),
              child: child,
            ),
          ),
          if (isCurrent)
            Positioned(
              top: 0,
              right: isRight ? null : 82,
              left: isRight ? 82 : null,
              child: _CurrentMascot(
                assetPath: mascotAssetPath,
                flip: isRight,
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentMascot extends StatelessWidget {
  final String assetPath;
  final bool flip;

  const _CurrentMascot({
    required this.assetPath,
    required this.flip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: flip ? TextDirection.rtl : TextDirection.ltr,
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(flip ? -1.0 : 1.0, 1.0),
          child: Image.asset(
            assetPath,
            width: 96,
            height: 96,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.primary,
                  size: 42,
                ),
              );
            },
          ),
        ),
        Transform.translate(
          offset: Offset(flip ? 8 : -8, 8),
          child: Transform.rotate(
            angle: flip ? -0.035 : 0.035,
            child: Container(
              width: 92,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                'يلا نكمل!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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