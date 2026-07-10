import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum JourneyStepStatus {
  completed,
  current,
  locked,
}

class JourneyStepItem extends StatelessWidget {
  final String label;
  final JourneyStepStatus status;
  final Color color;
  final VoidCallback? onTap;

  const JourneyStepItem({
    super.key,
    required this.label,
    required this.status,
    required this.color,
    this.onTap,
  });

  bool get isCurrent => status == JourneyStepStatus.current;
  bool get isCompleted => status == JourneyStepStatus.completed;
  bool get isLocked => status == JourneyStepStatus.locked;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: isCurrent ? 64 : 56,
      height: isCurrent ? 122 : 104,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (isCurrent)
            const Positioned(
              top: -3,
              child: Icon(
                Icons.flag_rounded,
                color: AppColors.primary,
                size: 24,
              ),
            ),

          Positioned(
            top: isCurrent ? 14 : 6,
            child: isCurrent
                ? const _CurrentMarker()
                : _NormalMarker(
              status: status,
              color: color,
            ),
          ),

          Positioned(
            top: isCurrent ? 78 : 61,
            child: Container(
              width: isCurrent ? 48 : 38,
              height: isCurrent ? 26 : 23,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.82),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                isCurrent ? 'الآن' : label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isCurrent
                      ? AppColors.white
                      : isLocked
                      ? AppColors.hint
                      : AppColors.textSecondary,
                  fontSize: isCurrent ? 11.5 : 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!isCurrent || onTap == null) {
      return content;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

class _NormalMarker extends StatelessWidget {
  final JourneyStepStatus status;
  final Color color;

  const _NormalMarker({
    required this.status,
    required this.color,
  });

  bool get isCompleted => status == JourneyStepStatus.completed;

  @override
  Widget build(BuildContext context) {
    final fillColor = isCompleted ? color : AppColors.inputFill;
    final iconColor = isCompleted ? AppColors.white : AppColors.hint;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 3.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? fillColor.withOpacity(0.20)
                : AppColors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: fillColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.lock_rounded,
            color: iconColor,
            size: isCompleted ? 21 : 17,
          ),
        ),
      ),
    );
  }
}

class _CurrentMarker extends StatefulWidget {
  const _CurrentMarker();

  @override
  State<_CurrentMarker> createState() => _CurrentMarkerState();
}

class _CurrentMarkerState extends State<_CurrentMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final glowOpacity = 0.13 + (_pulse.value * 0.14);
        final glowSpread = 0.7 + (_pulse.value * 1.8);

        return Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white,
              width: 3.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(glowOpacity),
                blurRadius: 16,
                spreadRadius: glowSpread,
              ),
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 49,
              height: 49,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.secondary,
                    AppColors.primary,
                  ],
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.white,
                size: 29,
              ),
            ),
          ),
        );
      },
    );
  }
}