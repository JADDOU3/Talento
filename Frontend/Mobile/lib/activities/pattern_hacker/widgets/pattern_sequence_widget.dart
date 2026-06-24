import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'pattern_icon_widget.dart';

/// Shows the pattern sequence followed by a blank slot at the END.
/// The blank slot displays the selected icon, or "؟" if nothing is picked yet.
///
/// [hintLevel] drives the visual hints:
///   1 -> glow the first two elements
///   2 -> gentle pulse animation on the sequence
///   4 -> highlight the repeating unit (its detected period)
class PatternSequenceWidget extends StatefulWidget {
  final List<String> sequence;
  final String? selectedIcon;
  final int hintLevel;

  const PatternSequenceWidget({
    super.key,
    required this.sequence,
    this.selectedIcon,
    this.hintLevel = 0,
  });

  @override
  State<PatternSequenceWidget> createState() => _PatternSequenceWidgetState();
}

class _PatternSequenceWidgetState extends State<PatternSequenceWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant PatternSequenceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    if (widget.hintLevel >= 2) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Smallest repeating period of the sequence (defaults to 2).
  int _detectPeriod(List<String> seq) {
    for (int p = 1; p <= seq.length ~/ 2; p++) {
      bool ok = true;
      for (int i = p; i < seq.length; i++) {
        if (seq[i] != seq[i - p]) {
          ok = false;
          break;
        }
      }
      if (ok) return p;
    }
    return seq.length >= 2 ? 2 : seq.length;
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.sequence;
    final totalSlots = sequence.length + 1;
    final iconSize = _iconSizeForCount(totalSlots);

    final glow = widget.hintLevel >= 1;
    final highlightUnit = widget.hintLevel >= 4;
    final period = _detectPeriod(sequence);

    final cells = <Widget>[
      for (int i = 0; i < sequence.length; i++)
        _SequenceCell(
          glow: glow && i < period,
          highlight: highlightUnit && i < period,
          child: buildPatternIcon(sequence[i], size: iconSize),
        ),
      _BlankSlot(selectedIcon: widget.selectedIcon, iconSize: iconSize),
    ];

    final row = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      textDirection: TextDirection.ltr, // blank slot always at the end
      children: cells,
    );

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
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.hintLevel >= 2 ? _pulse.value : 1.0,
                child: child,
              );
            },
            child: row,
          ),
        ],
      ),
    );
  }

  static double _iconSizeForCount(int count) {
    if (count >= 6) return 34;
    if (count >= 5) return 40;
    if (count >= 4) return 46;
    return 52;
  }
}

class _SequenceCell extends StatelessWidget {
  final Widget child;
  final bool glow;
  final bool highlight;

  const _SequenceCell({
    required this.child,
    this.glow = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.yellow.withOpacity(0.18)
            : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? AppColors.yellow
              : (glow
                  ? AppColors.secondary
                  : AppColors.primary.withOpacity(0.12)),
          width: (glow || highlight) ? 2.6 : 1,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.55),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class _BlankSlot extends StatelessWidget {
  final String? selectedIcon;
  final double iconSize;

  const _BlankSlot({
    required this.selectedIcon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = selectedIcon != null;

    return Container(
      width: 64,
      height: 64,
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
          ? buildPatternIcon(selectedIcon!, size: iconSize)
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
