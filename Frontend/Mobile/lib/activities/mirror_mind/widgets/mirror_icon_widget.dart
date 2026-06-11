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
    final normalizedIconName = iconName.trim().toLowerCase();

    final sizedShape = _SizedShapeIconData.tryParse(normalizedIconName);
    if (sizedShape != null) {
      return _SizedShapeIcon(
        shape: sizedShape.shape,
        size: size,
        isBig: sizedShape.isBig,
      );
    }

    if (_shouldRenderAsCombinedIcon(normalizedIconName)) {
      return buildCombinedIcon(normalizedIconName, size: size);
    }

    switch (normalizedIconName) {
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

      case 'dog':
        return _EmojiIcon(emoji: '🐶', size: size);

      case 'butterfly':
        return _EmojiIcon(emoji: '🦋', size: size);

      case 'flower':
        return _EmojiIcon(emoji: '🌸', size: size);

      case 'cat':
      case 'cat_face':
        return _EmojiIcon(emoji: '🐱', size: size);

      case 'small':
        return _PlainSizeCircle(
          size: size,
          isBig: false,
        );

      case 'big':
        return _PlainSizeCircle(
          size: size,
          isBig: true,
        );

      case 'arrow_left':
      case 'left_arrow':
        return _ArrowIcon(icon: Icons.arrow_back_rounded, size: size);

      case 'arrow_right':
      case 'right_arrow':
        return _ArrowIcon(icon: Icons.arrow_forward_rounded, size: size);

      case 'arrow_up':
      case 'up_arrow':
        return _ArrowIcon(icon: Icons.arrow_upward_rounded, size: size);

      case 'arrow_down':
      case 'down_arrow':
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
    final normalizedIcons = normalizeMirrorIconSequence(icons);

    if (normalizedIcons.isEmpty) {
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
      children: normalizedIcons
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

List<String> normalizeMirrorIconSequence(List<String> icons) {
  final cleaned = icons
      .map((icon) => icon.trim().toLowerCase())
      .where((icon) => icon.isNotEmpty)
      .toList();

  final result = <String>[];

  var i = 0;

  while (i < cleaned.length) {
    final current = cleaned[i];

    if (i + 1 < cleaned.length) {
      final next = cleaned[i + 1];

      if (_isShapeIcon(current) && _isSizeWord(next)) {
        result.add('${current}_$next');
        i += 2;
        continue;
      }

      if (_isSizeWord(current) && _isShapeIcon(next)) {
        result.add('${next}_$current');
        i += 2;
        continue;
      }
    }

    result.add(current);
    i++;
  }

  return result;
}

Widget buildCombinedIcon(
    String iconName, {
      double size = 48,
      double spacing = 6,
    }) {
  final sizedShape = _SizedShapeIconData.tryParse(iconName);
  if (sizedShape != null) {
    return _SizedShapeIcon(
      shape: sizedShape.shape,
      size: size,
      isBig: sizedShape.isBig,
    );
  }

  final parts = _splitCombinedIconName(iconName);

  if (parts.length <= 1) {
    return MirrorIconWidget(
      iconName: iconName,
      size: size,
    );
  }

  final normalizedParts = normalizeMirrorIconSequence(parts);

  if (normalizedParts.length == 1) {
    return MirrorIconWidget(
      iconName: normalizedParts.first,
      size: size,
    );
  }

  final miniSize = _miniSizeForCombined(
    baseSize: size,
    partsCount: normalizedParts.length,
  );

  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: normalizedParts
        .map(
          (part) => Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
        child: MirrorIconWidget(
          iconName: part,
          size: miniSize,
        ),
      ),
    )
        .toList(),
  );
}

double _miniSizeForCombined({
  required double baseSize,
  required int partsCount,
}) {
  if (partsCount >= 4) return baseSize * 0.62;
  if (partsCount == 3) return baseSize * 0.72;
  if (partsCount == 2) return baseSize * 0.80;

  return baseSize;
}

bool _shouldRenderAsCombinedIcon(String iconName) {
  if (!iconName.contains('_')) return false;
  if (_singleIconNamesWithUnderscore.contains(iconName)) return false;
  if (_SizedShapeIconData.tryParse(iconName) != null) return false;

  return _splitCombinedIconName(iconName).length > 1;
}

List<String> _splitCombinedIconName(String iconName) {
  final trimmedName = iconName.trim().toLowerCase();

  if (trimmedName.isEmpty) return <String>[];

  if (_singleIconNamesWithUnderscore.contains(trimmedName)) {
    return [trimmedName];
  }

  final rawParts = trimmedName
      .split('_')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  final parts = <String>[];

  for (var i = 0; i < rawParts.length; i++) {
    final current = rawParts[i];

    if (i + 1 < rawParts.length) {
      final twoWordIcon = '${rawParts[i]}_${rawParts[i + 1]}';

      if (_singleIconNamesWithUnderscore.contains(twoWordIcon)) {
        parts.add(twoWordIcon);
        i++;
        continue;
      }

      if (_isShapeIcon(rawParts[i]) && _isSizeWord(rawParts[i + 1])) {
        parts.add('${rawParts[i]}_${rawParts[i + 1]}');
        i++;
        continue;
      }

      if (_isSizeWord(rawParts[i]) && _isShapeIcon(rawParts[i + 1])) {
        parts.add('${rawParts[i + 1]}_${rawParts[i]}');
        i++;
        continue;
      }
    }

    parts.add(current);
  }

  return parts;
}

const Set<String> _singleIconNamesWithUnderscore = {
  'cat_face',
  'left_arrow',
  'right_arrow',
  'up_arrow',
  'down_arrow',
  'arrow_left',
  'arrow_right',
  'arrow_up',
  'arrow_down',
  'arrow_up_left',
  'arrow_up_right',
  'arrow_down_left',
  'arrow_down_right',
};

bool _isSizeWord(String value) {
  return value == 'big' || value == 'small';
}

bool _isShapeIcon(String value) {
  return value == 'circle' ||
      value == 'triangle' ||
      value == 'square' ||
      value == 'star';
}

class _SizedShapeIconData {
  final String shape;
  final bool isBig;

  const _SizedShapeIconData({
    required this.shape,
    required this.isBig,
  });

  static _SizedShapeIconData? tryParse(String rawIconName) {
    final iconName = rawIconName.trim().toLowerCase();

    final parts = iconName
        .split('_')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.length != 2) return null;

    final first = parts[0];
    final second = parts[1];

    if (_isShapeIcon(first) && _isSizeWord(second)) {
      return _SizedShapeIconData(
        shape: first,
        isBig: second == 'big',
      );
    }

    if (_isSizeWord(first) && _isShapeIcon(second)) {
      return _SizedShapeIconData(
        shape: second,
        isBig: first == 'big',
      );
    }

    return null;
  }
}

class _SizedShapeIcon extends StatelessWidget {
  final String shape;
  final double size;
  final bool isBig;

  const _SizedShapeIcon({
    required this.shape,
    required this.size,
    required this.isBig,
  });

  @override
  Widget build(BuildContext context) {
    final shapeSize = isBig ? size * 0.98 : size * 0.58;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: MirrorIconWidget(
          iconName: shape,
          size: shapeSize,
        ),
      ),
    );
  }
}

class _PlainSizeCircle extends StatelessWidget {
  final double size;
  final bool isBig;

  const _PlainSizeCircle({
    required this.size,
    required this.isBig,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = isBig ? size * 0.98 : size * 0.58;

    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: isBig
                ? AppColors.primary.withOpacity(0.18)
                : AppColors.secondary.withOpacity(0.22),
            shape: BoxShape.circle,
            border: Border.all(
              color: isBig ? AppColors.primary : AppColors.secondary,
              width: 2.3,
            ),
          ),
        ),
      ),
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