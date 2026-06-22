import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum JourneyStepStatus {
  completed,
  current,
  upcoming,
  locked,
}

class JourneyStepItem extends StatelessWidget {
  final String label;
  final JourneyStepStatus status;
  final IconData icon;

  const JourneyStepItem({
    super.key,
    required this.label,
    required this.status,
    required this.icon,
  });

  bool get isCurrent => status == JourneyStepStatus.current;

  Color get nodeColor {
    switch (status) {
      case JourneyStepStatus.completed:
        return AppColors.primary;
      case JourneyStepStatus.current:
        return AppColors.pink;
      case JourneyStepStatus.upcoming:
        return AppColors.secondary;
      case JourneyStepStatus.locked:
        return const Color(0xFFE7ECEF);
    }
  }

  Color get labelColor {
    switch (status) {
      case JourneyStepStatus.current:
        return AppColors.pink;
      case JourneyStepStatus.completed:
        return AppColors.primary;
      default:
        return AppColors.hint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isCurrent ? 45 : 34,
            height: isCurrent ? 45 : 34,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: isCurrent ? 5 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: nodeColor.withValues(alpha: isCurrent ? 0.28 : 0.10),
                  blurRadius: isCurrent ? 16 : 8,
                  offset: Offset(0, isCurrent ? 7 : 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: status == JourneyStepStatus.locked
                  ? AppColors.hint
                  : AppColors.white,
              size: isCurrent ? 19 : 15.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 10,
              height: 1,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
