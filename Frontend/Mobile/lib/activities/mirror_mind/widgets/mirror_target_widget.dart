import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/mirror_mind/mirror_mind_challenge_model.dart';
import '../../../models/activities/mirror_mind/mirror_mind_choice_model.dart';
import 'mirror_icon_widget.dart';

class MirrorTargetWidget extends StatelessWidget {
  final MirrorMindChallengeModel challenge;
  final MirrorMindChoiceModel? selectedChoice;

  /// Used only for Level 6.
  /// The game screen will show the sequence for 2 seconds, then pass false.
  final bool showMemorySequence;

  const MirrorTargetWidget({
    super.key,
    required this.challenge,
    this.selectedChoice,
    this.showMemorySequence = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _titleForChallenge(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DGAgnadeen',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          _buildChallengeLayout(),
        ],
      ),
    );
  }

  Widget _buildChallengeLayout() {
    switch (challenge.type) {
      case MirrorMindChallengeType.simpleReflection:
      case MirrorMindChallengeType.mirrorSequence:
      case MirrorMindChallengeType.directionReflection:
        return _buildClassicMirrorLayout();

      case MirrorMindChallengeType.symmetryCompletion:
        return _buildSymmetryCompletionLayout();

      case MirrorMindChallengeType.connectDotsMemory:
        return _buildConnectDotsLayout();

      case MirrorMindChallengeType.memorySequence:
        return _buildMemorySequenceLayout();

      case MirrorMindChallengeType.masterReflection:
        return _buildMasterReflectionLayout();

      case MirrorMindChallengeType.unknown:
        return _buildClassicMirrorLayout();
    }
  }

  Widget _buildClassicMirrorLayout() {
    final leftIcons = challenge.originalSideIcons;
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];

    return Row(
      children: [
        Expanded(
          child: _MirrorSideCard(
            label: 'هنا',
            child: MirrorIconSequence(
              icons: leftIcons,
              iconSize: _iconSizeForCount(leftIcons.length),
              spacing: 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _MirrorDivider(),
        const SizedBox(width: 12),
        Expanded(
          child: _MirrorSideCard(
            label: 'الانعكاس',
            isBlank: selectedIcons.isEmpty,
            child: selectedIcons.isEmpty
                ? const _BlankSlot()
                : MirrorIconSequence(
              icons: selectedIcons,
              iconSize: _iconSizeForCount(selectedIcons.length),
              spacing: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymmetryCompletionLayout() {
    final shape = challenge.shape ?? 'star';
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];
    final selectedShape = selectedIcons.isNotEmpty ? selectedIcons.first : '';

    final missingSide = challenge.missingSide?.toLowerCase() ?? 'left';

    final missingCard = _MirrorSideCard(
      label: 'النصف الناقص',
      isBlank: selectedShape.isEmpty,
      child: selectedShape.isEmpty
          ? const _BlankSlot()
          : _HalfShapeIcon(
        iconName: selectedShape,
        size: 66,
        isFaded: false,
      ),
    );

    final visibleCard = _MirrorSideCard(
      label: 'النصف الظاهر',
      child: _HalfShapeIcon(
        iconName: shape,
        size: 74,
        isFaded: false,
      ),
    );

    final children = missingSide == 'right'
        ? <Widget>[visibleCard, const _MirrorDivider(), missingCard]
        : <Widget>[missingCard, const _MirrorDivider(), visibleCard];

    return Row(
      children: [
        Expanded(child: children[0]),
        const SizedBox(width: 12),
        children[1],
        const SizedBox(width: 12),
        Expanded(child: children[2]),
      ],
    );
  }

  Widget _buildConnectDotsLayout() {
    final shape = challenge.shape ?? 'star';

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.12),
              width: 1.3,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(
                child: Center(
                  child: _DashedVerticalLine(height: 210),
                ),
              ),
              CustomPaint(
                size: const Size(210, 210),
                painter: _ConnectDotsPainter(shape: shape),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'أشعر أن شكلًا يختبئ هنا… هل يمكنك اكتشافه؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'ArialRounded',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemorySequenceLayout() {
    final sequence = challenge.sequence;

    return Column(
      children: [
        _MemorySequenceBox(
          icons: sequence,
          showIcons: showMemorySequence,
        ),
        const SizedBox(height: 12),
        Text(
          showMemorySequence
              ? 'تذكّر الترتيب جيدًا'
              : 'الآن اختَر الترتيب المعكوس',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'ArialRounded',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMasterReflectionLayout() {
    if (challenge.isSizeReflectionMode) {
      return _buildSizeReflectionLayout();
    }

    if (challenge.isSequenceReflectionMode) {
      return _buildSequenceReflectionLayout();
    }

    return _buildMasterClassicReflectionLayout();
  }

  Widget _buildMasterClassicReflectionLayout() {
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];

    return Row(
      children: [
        Expanded(
          child: _MirrorSideCard(
            label: 'التحدي',
            child: MirrorIconSequence(
              icons: challenge.items,
              iconSize: _iconSizeForCount(challenge.items.length),
              spacing: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _MirrorDivider(),
        const SizedBox(width: 12),
        Expanded(
          child: _MirrorSideCard(
            label: 'السر',
            isBlank: selectedIcons.isEmpty,
            child: selectedIcons.isEmpty
                ? const _BlankSlot()
                : MirrorIconSequence(
              icons: selectedIcons,
              iconSize: _iconSizeForCount(selectedIcons.length),
              spacing: 8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSequenceReflectionLayout() {
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];

    return Column(
      children: [
        _MirrorSideCard(
          label: 'السلسلة الأصلية',
          child: MirrorIconSequence(
            icons: challenge.items,
            iconSize: _iconSizeForCount(challenge.items.length),
            spacing: 8,
          ),
        ),
        const SizedBox(height: 12),
        const _HorizontalMirrorDivider(),
        const SizedBox(height: 12),
        _MirrorSideCard(
          label: 'الانعكاس المختار',
          isBlank: selectedIcons.isEmpty,
          child: selectedIcons.isEmpty
              ? const _BlankSlot()
              : MirrorIconSequence(
            icons: selectedIcons,
            iconSize: _iconSizeForCount(selectedIcons.length),
            spacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSizeReflectionLayout() {
    final prompt = challenge.prompt ?? 'big';
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];

    return Row(
      children: [
        Expanded(
          child: _MirrorSideCard(
            label: 'الكلمة',
            child: MirrorIconWidget(
              iconName: prompt,
              size: 76,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const _MirrorDivider(),
        const SizedBox(width: 12),
        Expanded(
          child: _MirrorSideCard(
            label: 'العكس',
            isBlank: selectedIcons.isEmpty,
            child: selectedIcons.isEmpty
                ? const _BlankSlot()
                : MirrorIconSequence(
              icons: selectedIcons,
              iconSize: 62,
              spacing: 8,
            ),
          ),
        ),
      ],
    );
  }

  String _titleForChallenge() {
    switch (challenge.type) {
      case MirrorMindChallengeType.simpleReflection:
        return 'أين يظهر انعكاس الشكل؟';

      case MirrorMindChallengeType.mirrorSequence:
        return 'اختَر ترتيب الأشكال في المرآة';

      case MirrorMindChallengeType.directionReflection:
        return 'كيف يبدو الاتجاه في المرآة؟';

      case MirrorMindChallengeType.symmetryCompletion:
        return 'أكمل النصف الناقص';

      case MirrorMindChallengeType.connectDotsMemory:
        return 'الرسم بالنقاط';

      case MirrorMindChallengeType.memorySequence:
        return 'تذكّر ثم اعكس الترتيب';

      case MirrorMindChallengeType.masterReflection:
        return 'هنا يوجد أكثر من سر!';

      case MirrorMindChallengeType.unknown:
        return 'اختَر الإجابة الصحيحة';
    }
  }

  static double _iconSizeForCount(int count) {
    if (count >= 3) return 34;
    if (count == 2) return 40;
    return 54;
  }
}

class _MirrorSideCard extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isBlank;

  const _MirrorSideCard({
    required this.label,
    required this.child,
    this.isBlank = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBlank
            ? AppColors.inputFill.withOpacity(0.78)
            : AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBlank
              ? AppColors.border
              : AppColors.primary.withOpacity(0.16),
          width: 1.3,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Center(child: child),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MirrorDivider extends StatelessWidget {
  const _MirrorDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary,
            AppColors.primary,
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.55),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _HorizontalMirrorDivider extends StatelessWidget {
  const _HorizontalMirrorDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary,
            AppColors.primary,
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.45),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _BlankSlot extends StatelessWidget {
  const _BlankSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 2,
        ),
      ),
      child: const Text(
        '؟',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _HalfShapeIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final bool isFaded;

  const _HalfShapeIcon({
    required this.iconName,
    required this.size,
    required this.isFaded,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isFaded ? 0.45 : 1,
      child: ClipRect(
        child: Align(
          alignment: Alignment.center,
          widthFactor: 0.62,
          child: MirrorIconWidget(
            iconName: iconName,
            size: size,
          ),
        ),
      ),
    );
  }
}

class _MemorySequenceBox extends StatelessWidget {
  final List<String> icons;
  final bool showIcons;

  const _MemorySequenceBox({
    required this.icons,
    required this.showIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.16),
          width: 1.3,
        ),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: showIcons
              ? MirrorIconSequence(
            key: const ValueKey('memory-icons'),
            icons: icons,
            iconSize: icons.length >= 3 ? 36 : 46,
            spacing: 12,
          )
              : Wrap(
            key: const ValueKey('memory-placeholders'),
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              icons.length,
                  (_) => const _SmallBlankSlot(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallBlankSlot extends StatelessWidget {
  const _SmallBlankSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Text(
          '?',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DashedVerticalLine extends StatelessWidget {
  final double height;

  const _DashedVerticalLine({
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(2, height),
      painter: _DashedLinePainter(),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.35)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const dashHeight = 7.0;
    const dashSpace = 6.0;

    var y = 0.0;

    while (y < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, y),
        Offset(size.width / 2, math.min(y + dashHeight, size.height)),
        paint,
      );
      y += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConnectDotsPainter extends CustomPainter {
  final String shape;

  const _ConnectDotsPainter({
    required this.shape,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = _pointsForShape(shape, size);

    final linePaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.45)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      if (shape.toLowerCase() == 'star' || shape.toLowerCase() == 'flower') {
        path.close();
      }

      canvas.drawPath(path, linePaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];

      canvas.drawCircle(point, 6.5, Paint()..color = AppColors.white);
      canvas.drawCircle(point, 5.4, dotPaint);

      if (i < 5) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(point.dx + 8, point.dy - 15),
        );
      }
    }
  }

  List<Offset> _pointsForShape(String rawShape, Size size) {
    final shapeName = rawShape.toLowerCase();
    final center = Offset(size.width / 2, size.height / 2);

    if (shapeName == 'flower') {
      return [
        center,
        ...List.generate(6, (index) {
          final angle = -math.pi / 2 + index * (2 * math.pi / 6);
          return Offset(
            center.dx + math.cos(angle) * size.width * 0.34,
            center.dy + math.sin(angle) * size.height * 0.34,
          );
        }),
      ];
    }

    if (shapeName == 'butterfly') {
      return [
        Offset(size.width * 0.50, size.height * 0.20),
        Offset(size.width * 0.30, size.height * 0.30),
        Offset(size.width * 0.20, size.height * 0.50),
        Offset(size.width * 0.34, size.height * 0.66),
        Offset(size.width * 0.50, size.height * 0.52),
        Offset(size.width * 0.66, size.height * 0.66),
        Offset(size.width * 0.80, size.height * 0.50),
        Offset(size.width * 0.70, size.height * 0.30),
      ];
    }

    // Default: star
    final points = <Offset>[];
    final outerRadius = size.width * 0.38;
    final innerRadius = size.width * 0.17;

    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = -math.pi / 2 + i * math.pi / 5;

      points.add(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
      );
    }

    return points;
  }

  @override
  bool shouldRepaint(covariant _ConnectDotsPainter oldDelegate) {
    return oldDelegate.shape != shape;
  }
}