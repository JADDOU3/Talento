import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

const Map<String, String> _storySpinnerArabicIconNames = {
  'cat': 'قطة',
  'robot': 'روبوت',
  'frog': 'ضفدع',
  'penguin': 'بطريق',
  'unicorn': 'وحيد القرن',
  'travels': 'رحلة',
  'search': 'بحث',
  'running_from_rain': 'الهروب من المطر',
  'fly': 'طيران',
  'sing': 'غناء',
  'forest': 'غابة',
  'castle': 'قلعة',
  'moon': 'القمر',
  'sea': 'البحر',
  'volcano': 'بركان',
};

TextDirection _directionForText(String text) {
  final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  return hasArabic ? TextDirection.rtl : TextDirection.ltr;
}

String _displayNameForIcon(String icon) {
  return _storySpinnerArabicIconNames[icon] ?? icon.replaceAll('_', ' ');
}

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
      duration: const Duration(milliseconds: 1750),
    );

    _rotationAnimation = AlwaysStoppedAnimation(_currentTurns);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (widget.icons.isEmpty || widget.isSpinning || _controller.isAnimating) {
      return;
    }

    widget.onSpin();

    final count = widget.icons.length;
    final landedIndex = _random.nextInt(count);
    final landedIcon = widget.icons[landedIndex];

    final currentNormalized = _normalizeTurns(_currentTurns);
    final targetNormalized = _normalizeTurns(1 - (landedIndex / count));

    double delta = targetNormalized - currentNormalized;
    if (delta < 0) delta += 1;

    final targetTurns = _currentTurns + 4 + _random.nextInt(2) + delta;

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

    _currentTurns = _normalizeTurns(targetTurns);

    if (!mounted) return;

    widget.onLanded(landedIcon);
  }

  double _normalizeTurns(double turns) {
    final value = turns % 1;
    return value < 0 ? value + 1 : value;
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = !widget.isSpinning &&
        !_controller.isAnimating &&
        widget.icons.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _WheelTitle(
            label: widget.label,
            question: widget.question,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 226,
            height: 226,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const _SoftGlow(),
                const Positioned(
                  top: 0,
                  child: _Pointer(),
                ),
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: _WheelDisk(icons: widget.icons),
                ),
                _CenterSpinButton(
                  enabled: canSpin,
                  spinning: widget.isSpinning || _controller.isAnimating,
                  onTap: _spin,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: widget.landedIcon == null
                ? Text(
              'Tap Spin',
              key: const ValueKey('tap-spin'),
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            )
                : _ResultChip(
              key: ValueKey(widget.landedIcon),
              icon: widget.landedIcon!,
            ),
          ),
        ],
      ),
    );
  }
}

class _WheelTitle extends StatelessWidget {
  final String label;
  final String question;

  const _WheelTitle({
    required this.label,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          question,
          textAlign: TextAlign.center,
          textDirection: _directionForText(question),
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 16,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            textDirection: _directionForText(label),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SoftGlow extends StatelessWidget {
  const _SoftGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 218,
      height: 218,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD24D).withOpacity(0.16),
            blurRadius: 18,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.055),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _WheelDisk extends StatelessWidget {
  final List<String> icons;

  const _WheelDisk({
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    final safeIcons = icons.isEmpty ? <String>['?'] : icons;
    final count = safeIcons.length;

    return Container(
      width: 198,
      height: 198,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFFD24D),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(7),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withOpacity(0.95),
        ),
        padding: const EdgeInsets.all(3),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size.square(178),
              painter: _WheelPainter(segmentCount: count),
            ),
            ...List.generate(count, (index) {
              final sweep = (2 * math.pi) / count;
              final angle = (-math.pi / 2) + (index * sweep);
              const radius = 61.0;

              return Transform.translate(
                offset: Offset(
                  math.cos(angle) * radius,
                  math.sin(angle) * radius,
                ),
                child: _WheelIcon(icon: safeIcons[index]),
              );
            }),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
                border: Border.all(
                  color: const Color(0xFFFFD24D),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.055),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        ),
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
    final count = segmentCount <= 0 ? 1 : segmentCount;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final colors = [
      const Color(0xFFF7B9C9),
      const Color(0xFFC9D7FF),
      const Color(0xFFBDE9F2),
      const Color(0xFFCDECC8),
      const Color(0xFFF9E2A8),
      const Color(0xFFE3CBF5),
    ];

    final sweep = 2 * math.pi / count;

    for (int i = 0; i < count; i++) {
      final startAngle = (-math.pi / 2) - (sweep / 2) + (i * sweep);

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i % colors.length];

      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        true,
        paint,
      );
    }

    final separatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.white.withOpacity(0.72);

    for (int i = 0; i < count; i++) {
      final angle = (-math.pi / 2) - (sweep / 2) + (i * sweep);

      canvas.drawLine(
        center,
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        separatorPaint,
      );
    }

    final overlayPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.white.withOpacity(0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);

    canvas.drawCircle(center, radius, overlayPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.white.withOpacity(0.82);

    canvas.drawCircle(center, radius - 1, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.segmentCount != segmentCount;
  }
}

class _CenterSpinButton extends StatelessWidget {
  final bool enabled;
  final bool spinning;
  final VoidCallback onTap;

  const _CenterSpinButton({
    required this.enabled,
    required this.spinning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = enabled
        ? const LinearGradient(
      colors: [
        Color(0xFFFFF2A3),
        Color(0xFFFFD24D),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    )
        : LinearGradient(
      colors: [
        AppColors.border,
        AppColors.border.withOpacity(0.75),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: background,
            border: Border.all(
              color: AppColors.white.withOpacity(0.96),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFC640).withOpacity(enabled ? 0.22 : 0),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              spinning ? '...' : 'Spin',
              textDirection: TextDirection.ltr,
              style: AppTextStyles.button.copyWith(
                fontFamily: 'BerlinSans',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: enabled ? AppColors.primary : AppColors.hint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pointer extends StatelessWidget {
  const _Pointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(42, 34),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = AppColors.black.withOpacity(0.09)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final shadowPath = Path()
      ..moveTo(size.width / 2, size.height + 1)
      ..lineTo(5, 6)
      ..quadraticBezierTo(size.width / 2, -1, size.width - 5, 6)
      ..close();

    canvas.drawPath(shadowPath, shadowPaint);

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(5, 6)
      ..quadraticBezierTo(size.width / 2, 0, size.width - 5, 6)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFF2A3),
          Color(0xFFFFD24D),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = AppColors.white.withOpacity(0.92);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelIcon extends StatelessWidget {
  final String icon;

  const _WheelIcon({
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackLetter =
    icon.trim().isEmpty ? '?' : icon.trim().substring(0, 1).toUpperCase();

    return Container(
      width: 43,
      height: 43,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(0.95),
        border: Border.all(
          color: AppColors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.075),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/cards/$icon.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              fallbackLetter,
              textDirection: TextDirection.ltr,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
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

class _ResultChip extends StatelessWidget {
  final String icon;

  const _ResultChip({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = _displayNameForIcon(icon);

    return Container(
      key: ValueKey(icon),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 7,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: _directionForText(displayName),
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/images/cards/$icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.primary,
                  size: 18,
                );
              },
            ),
          ),
          const SizedBox(width: 7),
          Text(
            displayName,
            textDirection: _directionForText(displayName),
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}