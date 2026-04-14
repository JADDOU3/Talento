import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7FCFC),
            Color(0xFFF4FBFA),
            Color(0xFFFFF9FB),
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildShape(
            top: -90,
            left: -70,
            size: 220,
            color: AppColors.secondary.withValues(alpha: 0.14),
          ),
          _buildShape(
            top: 100,
            right: -60,
            size: 180,
            color: AppColors.pink.withValues(alpha: 0.10),
          ),
          _buildShape(
            bottom: -70,
            left: -40,
            size: 190,
            color: AppColors.yellow.withValues(alpha: 0.10),
          ),
          _buildShape(
            bottom: 80,
            right: -80,
            size: 220,
            color: AppColors.primary.withValues(alpha: 0.10),
          ),

          _buildShape(
            top: 250,
            left: -60,
            size: 160,
            color: AppColors.red.withValues(alpha: 0.08),
          ),

          SafeArea(child: child),
        ],
      ),
    );
  }

  Widget _buildShape({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}