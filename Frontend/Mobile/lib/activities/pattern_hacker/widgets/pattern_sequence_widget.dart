import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'pattern_icon_widget.dart';

/// Displays the complete pattern in one horizontal RTL row.
///
/// The first sequence item appears on the right, the following items continue
/// toward the left, and the answer slot stays at the visual end of the pattern.
/// The row is scaled down when necessary so it never wraps onto a second line.
class PatternSequenceWidget extends StatelessWidget {
  final List<String> sequence;
  final String? selectedIcon;

  const PatternSequenceWidget({
    super.key,
    required this.sequence,
    this.selectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final totalSlots = sequence.length + 1;
    final cellSize = _cellSizeForCount(totalSlots);
    final iconSize = _iconSizeForCount(totalSlots);
    final spacing = _spacingForCount(totalSlots);

    final cells = <Widget>[
      for (final iconName in sequence)
        _SequenceCell(
          size: cellSize,
          child: buildPatternIcon(
            iconName,
            size: iconSize,
          ),
        ),
      _BlankSlot(
        selectedIcon: selectedIcon,
        cellSize: cellSize,
        iconSize: iconSize,
      ),
    ];

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
          const Text(
            'ما هو الشكل التالي؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DGAgnadeen',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: TextDirection.rtl,
                children: [
                  for (int index = 0; index < cells.length; index++) ...[
                    cells[index],
                    if (index != cells.length - 1)
                      SizedBox(width: spacing),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _cellSizeForCount(int count) {
    if (count >= 7) return 58;
    if (count >= 6) return 60;
    return 64;
  }

  static double _iconSizeForCount(int count) {
    if (count >= 7) return 34;
    if (count >= 6) return 38;
    if (count >= 5) return 42;
    if (count >= 4) return 46;
    return 50;
  }

  static double _spacingForCount(int count) {
    if (count >= 7) return 7;
    if (count >= 6) return 8;
    return 10;
  }
}

class _SequenceCell extends StatelessWidget {
  final Widget child;
  final double size;

  const _SequenceCell({
    required this.child,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _BlankSlot extends StatelessWidget {
  final String? selectedIcon;
  final double cellSize;
  final double iconSize;

  const _BlankSlot({
    required this.selectedIcon,
    required this.cellSize,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = selectedIcon != null;

    return Container(
      width: cellSize,
      height: cellSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isFilled
            ? AppColors.secondary.withOpacity(0.16)
            : AppColors.inputFill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFilled
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.25),
          width: isFilled ? 2.4 : 2,
        ),
      ),
      child: isFilled
          ? buildPatternIcon(
        selectedIcon!,
        size: iconSize,
      )
          : const Text(
        '؟',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
