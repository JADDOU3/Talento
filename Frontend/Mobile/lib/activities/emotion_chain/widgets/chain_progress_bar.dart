import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Shows the emotion chain steps as connected badges.
/// Completed steps are checked, the current step is highlighted, upcoming
/// steps are greyed out.
class ChainProgressBar extends StatelessWidget {
  final List<String> steps; // e.g. ["feeling", "feeling", "action", "outcome"]
  final int currentIndex;

  const ChainProgressBar({
    super.key,
    required this.steps,
    required this.currentIndex,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepBadge(
              label: _labels[steps[i]] ?? steps[i],
              icon: _icons[steps[i]] ?? '•',
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
        : (isDone ? AppColors.secondary.withValues(alpha: 0.20) : AppColors.inputFill);
    final Color border = isCurrent
        ? AppColors.primary
        : (isDone ? AppColors.secondary : AppColors.border);
    final Color textColor = isCurrent ? AppColors.white : AppColors.textSecondary;

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
          Text(
            isDone ? '✅' : icon,
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
        ],
      ),
    );
  }
}
