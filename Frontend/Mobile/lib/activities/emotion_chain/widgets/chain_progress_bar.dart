import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shows the emotion chain steps as connected badges.
/// Completed steps are checked, the current step is highlighted, upcoming
/// steps are greyed out.
///
/// When two "feeling" steps belong to two different children, they are shown
/// with each child's avatar (👦 / 👧) so they read distinctly — no numbering.
class ChainProgressBar extends StatelessWidget {
  final List<String> steps; // e.g. ["feeling", "feeling", "action", "outcome"]
  final int currentIndex;

  /// Optional character per step (1 or 2), parallel to [steps].
  final List<int?>? characters;

  const ChainProgressBar({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.characters,
  });

  static const Map<String, String> _labels = {
    'feeling': 'المشاعر',
    'action': 'التصرّف',
    'outcome': 'النتيجة',
  };

  static const Map<String, String> _icons = {
    'feeling': '😔',
    'action': '🤝',
    'outcome': '🎉',
  };

  int? _characterAt(int i) {
    if (characters == null || i >= characters!.length) return null;
    return characters![i];
  }

  String _iconFor(int i) {
    final step = steps[i];
    if (step == 'feeling') {
      final c = _characterAt(i);
      if (c == 1) return '👦';
      if (c == 2) return '👧';
    }
    return _icons[step] ?? '•';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepBadge(
              label: _labels[steps[i]] ?? steps[i],
              icon: _iconFor(i),
              status: i < currentIndex
                  ? _StepStatus.done
                  : (i == currentIndex
                      ? _StepStatus.current
                      : _StepStatus.upcoming),
            ),
            if (i < steps.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.arrow_back_rounded, // RTL: arrow points to next (left)
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum _StepStatus { done, current, upcoming }

class _StepBadge extends StatelessWidget {
  final String label;
  final String icon;
  final _StepStatus status;

  const _StepBadge({
    required this.label,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = status == _StepStatus.current;
    final bool isDone = status == _StepStatus.done;

    final Color bg = isCurrent
        ? AppColors.primary
        : (isDone
            ? AppColors.secondary.withValues(alpha: 0.20)
            : AppColors.inputFill);
    final Color border = isCurrent
        ? AppColors.primary
        : (isDone ? AppColors.secondary : AppColors.border);
    final Color textColor =
        isCurrent ? AppColors.white : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: isCurrent ? 2 : 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Keep the child avatar visible even when done, so the two feeling
          // steps stay distinguishable; other done steps show a check.
          Text(
            isDone ? (_isAvatar(icon) ? icon : '✅') : icon,
            style: const TextStyle(fontSize: 16),
            textDirection: TextDirection.ltr,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          if (isDone) ...[
            const SizedBox(width: 4),
            const Text('✓',
                style: TextStyle(fontSize: 12, color: AppColors.secondary)),
          ],
        ],
      ),
    );
  }

  bool _isAvatar(String s) => s == '👦' || s == '👧';
}
