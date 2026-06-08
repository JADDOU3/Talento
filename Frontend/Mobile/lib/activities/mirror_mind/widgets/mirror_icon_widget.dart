import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MirrorIconWidget extends StatelessWidget {
  final String iconName;
  final double size;

  const MirrorIconWidget({
    super.key,
    required this.iconName,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    switch (iconName) {
      case 'triangle':
        return CustomPaint(
          size: Size(size, size),
          painter: _TrianglePainter(),
        );

      case 'circle':
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
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

      case 'star':
        return Icon(
          Icons.star_rounded,
          size: size,
          color: AppColors.yellow,
        );

      case 'fish':
        return _EmojiIcon(emoji: '🐟', size: size);

      case 'apple':
        return _EmojiIcon(emoji: '🍎', size: size);

      case 'banana':
        return _EmojiIcon(emoji: '🍌', size: size);

      case 'arrow_left':
        return _ArrowIcon(icon: Icons.arrow_back_rounded, size: size);

      case 'arrow_right':
        return _ArrowIcon(icon: Icons.arrow_forward_rounded, size: size);

      case 'arrow_up':
        return _ArrowIcon(icon: Icons.arrow_upward_rounded, size: size);

      case 'arrow_down':
        return _ArrowIcon(icon: Icons.arrow_downward_rounded, size: size);

      case 'arrow_up_left':
        return Transform.rotate(
          angle: -0.8,
          child: _ArrowIcon(icon: Icons.arrow_back_rounded, size: size),
        );

      case 'arrow_up_right':
        return Transform.rotate(
          angle: 0.8,
          child: _ArrowIcon(icon: Icons.arrow_forward_rounded, size: size),
        );

      case 'arrow_down_left':
        return Transform.rotate(
          angle: 0.8,
          child: _ArrowIcon(icon: Icons.arrow_back_rounded, size: size),
        );

      case 'arrow_down_right':
        return Transform.rotate(
          angle: -0.8,
          child: _ArrowIcon(icon: Icons.arrow_forward_rounded, size: size),
        );

      default:
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
}

class MirrorIconSequence extends StatelessWidget {
  final List<String> icons;
  final double iconSize;
  final double spacing;

  const MirrorIconSequence({
    super.key,
    required this.icons,
    this.iconSize = 44,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (icons.isEmpty) {
      return MirrorIconWidget(
        iconName: 'unknown',
        size: iconSize,
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      runSpacing: spacing,
      children: icons
          .map(
            (icon) => MirrorIconWidget(
          iconName: icon,
          size: iconSize,
        ),
      )
          .toList(),
    );
  }
}

class _EmojiIcon extends StatelessWidget {
  final String emoji;
  final double size;

  const _EmojiIcon({
    required this.emoji,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      emoji,
      textDirection: TextDirection.ltr,
      style: TextStyle(
        fontSize: size * 0.86,
        height: 1,
      ),
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _ArrowIcon({
    required this.icon,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size,
      color: AppColors.primary,
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