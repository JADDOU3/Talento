import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class JournalCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double radius;

  const JournalCard({
    super.key,
    required this.child,
    this.color = AppColors.cardBackground,
    this.borderColor,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}