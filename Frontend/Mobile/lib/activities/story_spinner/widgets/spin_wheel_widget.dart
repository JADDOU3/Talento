import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SpinWheelWidget extends StatefulWidget {
  final String label;
  final String question;
  final List<String> icons;
  final String? landedIcon;
  final VoidCallback onSpin;
  final ValueChanged<String> onLanded;
  final bool isSpinning;

  const SpinWheelWidget({
    super.key,
    required this.label,
    required this.question,
    required this.icons,
    required this.landedIcon,
    required this.onSpin,
    required this.onLanded,
    required this.isSpinning,
  });

  @override
  State<SpinWheelWidget> createState() => _SpinWheelWidgetState();
}

class _SpinWheelWidgetState extends State<SpinWheelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;

  final math.Random _random = math.Random();

  double _currentTurns = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _rotationAnimation = AlwaysStoppedAnimation(_currentTurns);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (widget.isSpinning || widget.icons.isEmpty || _controller.isAnimating) {
      return;
    }

    widget.onSpin();

    final landedIndex = _random.nextInt(widget.icons.length);
    final landedIcon = widget.icons[landedIndex];

    final segmentTurns = widget.icons.length <= 1
        ? 0.0
        : landedIndex / widget.icons.length;

    final extraTurns = 4 + _random.nextInt(3);
    final targetTurns = _currentTurns + extraTurns + segmentTurns;

    _rotationAnimation = Tween<double>(
      begin: _currentTurns,
      end: targetTurns,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    setState(() {});

    await _controller.forward(from: 0);

    _currentTurns = targetTurns % 1;

    if (!mounted) return;

    widget.onLanded(landedIcon);
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = !widget.isSpinning &&
        !_controller.isAnimating &&
        widget.icons.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.14),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.question,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 156,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 42,
                    color: AppColors.pink,
                  ),
                ),
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: _WheelCircle(icons: widget.icons),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: widget.landedIcon == null
                ? Text(
              'اضغطي Spin لاختيار عنصر',
              key: const ValueKey('empty'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            )
                : _LandedResult(
              key: ValueKey(widget.landedIcon),
              icon: widget.landedIcon!,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: canSpin ? _spin : null,
              icon: const Icon(Icons.casino_rounded, size: 20),
              label: Text(
                widget.isSpinning || _controller.isAnimating
                    ? 'Spinning...'
                    : 'Spin',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.border,
                foregroundColor: AppColors.white,
                elevation: canSpin ? 3 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: AppTextStyles.button.copyWith(
                  fontSize: 15,
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

class _WheelCircle extends StatelessWidget {
  final List<String> icons;

  const _WheelCircle({
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final safeIcons = icons.isEmpty ? <String>['?'] : icons;
    final count = safeIcons.length;

    return SizedBox(
      width: 142,
      height: 142,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size.square(142),
            painter: _WheelPainter(segmentCount: count),
          ),
          ...List.generate(count, (index) {
            final angle = (2 * math.pi * index / count) - math.pi / 2;
            final radius = count <= 2 ? 38.0 : 48.0;

            final x = math.cos(angle) * radius;
            final y = math.sin(angle) * radius;

            return Transform.translate(
              offset: Offset(x, y),
              child: _WheelIcon(icon: safeIcons[index]),
            );
          }),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final int segmentCount;

  const _WheelPainter({
    required this.segmentCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final colors = [
      AppColors.primary.withOpacity(0.22),
      AppColors.secondary.withOpacity(0.24),
      AppColors.yellow.withOpacity(0.36),
      AppColors.pink.withOpacity(0.23),
      AppColors.primary.withOpacity(0.14),
      AppColors.secondary.withOpacity(0.16),
    ];

    final count = segmentCount <= 0 ? 1 : segmentCount;
    final sweep = 2 * math.pi / count;

    for (int i = 0; i < count; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];

      canvas.drawArc(
        rect,
        -math.pi / 2 + (i * sweep),
        sweep,
        true,
        paint,
      );
    }

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = AppColors.white;

    canvas.drawCircle(center, radius - 2, borderPaint);

    final softBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.primary.withOpacity(0.22);

    canvas.drawCircle(center, radius - 4, softBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount;
  }
}

class _WheelIcon extends StatelessWidget {
  final String icon;

  const _WheelIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackLetter = icon.trim().isEmpty
        ? '?'
        : icon.trim().substring(0, 1).toUpperCase();

    return Container(
      width: 34,
      height: 34,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/images/cards/$icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              fallbackLetter,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LandedResult extends StatelessWidget {
  final String icon;

  const _LandedResult({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        key: ValueKey(icon),
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(
              'assets/images/cards/$icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.primary,
                  size: 22,
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Text(
            icon.replaceAll('_', ' '),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}