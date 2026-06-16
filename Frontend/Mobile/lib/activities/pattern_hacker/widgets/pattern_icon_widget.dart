import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Central icon renderer. Every visual in Pattern Hacker is drawn from an icon
/// NAME string (s3Key is always empty and is never used).
///
/// This function is reused by both the sequence widget and the choices widget.
Widget buildPatternIcon(String iconName, {double size = 48}) {
  switch (iconName) {
    // ---- Circles ----
    case 'circle':
      return _Circle(size: size, color: AppColors.secondary);
    case 'circle_filled':
      return _Circle(size: size, color: AppColors.secondary);

    case 'circle_outline':
      return _Circle(size: size, color: Colors.transparent, borderColor: AppColors.secondary);

    case 'circle_dashed':
      return CustomPaint(
        size: Size(size, size),
        painter: _DashedCirclePainter(color: AppColors.secondary),
      );

    case 'circle_black':
      return _Circle(size: size, color: AppColors.black);

    case 'circle_colored':
      return _Circle(size: size, color: AppColors.pink);

    // ---- Shapes ----
    case 'triangle':
      return CustomPaint(
        size: Size(size, size),
        painter: _TrianglePainter(),
      );

    case 'square':
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(size * 0.16),
        ),
      );

    // ---- Stars / heart ----
    case 'star':
    case 'star_filled':
      return Icon(Icons.star_rounded, size: size, color: AppColors.yellow);

    case 'star_outline':
      return Icon(Icons.star_border_rounded, size: size, color: AppColors.yellow);

    case 'heart':
      return Icon(Icons.favorite_rounded, size: size, color: AppColors.pink);

    // ---- Arrows ----
    case 'arrow_left':
      return _Arrow(icon: Icons.arrow_back_rounded, size: size);

    case 'arrow_right':
      return _Arrow(icon: Icons.arrow_forward_rounded, size: size);

    case 'arrow_up':
      return _Arrow(icon: Icons.arrow_upward_rounded, size: size);

    case 'arrow_down':
      return _Arrow(icon: Icons.arrow_downward_rounded, size: size);

    case 'arrow_up_left':
      return Transform.rotate(
        angle: -0.8,
        child: _Arrow(icon: Icons.arrow_back_rounded, size: size),
      );

    case 'arrow_up_right':
      return Transform.rotate(
        angle: 0.8,
        child: _Arrow(icon: Icons.arrow_forward_rounded, size: size),
      );
    case 'arrow_down_left':
      return Transform.rotate(
        angle: 0.8,
        child: _Arrow(icon: Icons.arrow_back_rounded, size: size),
      );
    case 'arrow_down_right':
      return Transform.rotate(
        angle: -0.8,
        child: _Arrow(icon: Icons.arrow_forward_rounded, size: size),
      );

    // ---- Fruits ----
    case 'apple':
      return _Emoji(emoji: '🍎', size: size);
    case 'banana':
      return _Emoji(emoji: '🍌', size: size);
    case 'grapes':
      return _Emoji(emoji: '🍇', size: size);
    case 'strawberry':
      return _Emoji(emoji: '🍓', size: size);
    case 'watermelon':
      return _Emoji(emoji: '🍉', size: size);
    case 'orange':
      return _Emoji(emoji: '🍊', size: size);

    // ---- Animals ----
    case 'cow':
      return _Emoji(emoji: '🐮', size: size);
    case 'cat':
      return _Emoji(emoji: '🐱', size: size);
    case 'dog':
      return _Emoji(emoji: '🐶', size: size);
    case 'rabbit':
      return _Emoji(emoji: '🐰', size: size);
    case 'fish':
      return _Emoji(emoji: '🐟', size: size);
    case 'turtle':
      return _Emoji(emoji: '🐢', size: size);

    // ---- Numbers ----
    case '1':
    case '2':
    case '3':
    case '4':
      return _NumberIcon(text: iconName, size: size);

    // ---- Fallback ----
    default:
      return _QuestionBox(size: size);
  }
}

/// Optional widget wrapper around [buildPatternIcon].
class PatternIconWidget extends StatelessWidget {
  final String iconName;
  final double size;

  const PatternIconWidget({
    super.key,
    required this.iconName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) => buildPatternIcon(iconName, size: size);
}

// =============================================================================
// Internal building blocks
// =============================================================================

class _Circle extends StatelessWidget {
  final double size;
  final Color color;
  final Color? borderColor;

  const _Circle({
    required this.size,
    required this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: size * 0.09)
            : null,
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final double size;

  const _Arrow({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: AppColors.primary);
  }
}

class _Emoji extends StatelessWidget {
  final String emoji;
  final double size;

  const _Emoji({required this.emoji, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textDirection: TextDirection.ltr,
      style: TextStyle(fontSize: size * 0.86, height: 1),
    );
  }
}

class _NumberIcon extends StatelessWidget {
  final String text;
  final double size;

  const _NumberIcon({required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: size * 0.7,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _QuestionBox extends StatelessWidget {
  final double size;

  const _QuestionBox({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '؟',
        style: TextStyle(
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.pink
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09
      ..strokeCap = StrokeCap.round;

    final radius = (size.width - paint.strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    const dashCount = 12;
    final dashAngle = (2 * math.pi) / dashCount;
    final gap = dashAngle * 0.45;

    for (int i = 0; i < dashCount; i++) {
      final start = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashAngle - gap,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
