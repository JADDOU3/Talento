import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Countdown bar shown on Level 1 step screens only.
class TimerBarWidget extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;

  const TimerBarWidget({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final ratio =
        totalSeconds <= 0 ? 0.0 : (remainingSeconds / totalSeconds).clamp(0.0, 1.0);
    final isLow = remainingSeconds <= 3;
    final barColor = isLow ? AppColors.red : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.timer_rounded, size: 20, color: barColor),
                const SizedBox(width: 6),
                Text(
                  'الوقت المتبقّي',
                  style: TextStyle(
                    fontFamily: 'ArialRounded',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              '$remainingSeconds ث',
              style: TextStyle(
                fontFamily: 'ArialRounded',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: AppColors.inputFill,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
