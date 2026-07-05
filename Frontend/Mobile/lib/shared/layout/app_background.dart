import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBackground extends StatefulWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            top: -80,
            left: -60,
            size: 200,
            color: AppColors.secondary.withValues(alpha: 0.12),
          ),
          _buildShape(
            top: 100,
            right: -60,
            size: 170,
            color: AppColors.pink.withValues(alpha: 0.12),
          ),
          _buildShape(
            bottom: -70,
            left: -40,
            size: 200,
            color: AppColors.yellow.withValues(alpha: 0.12),
          ),
          _buildShape(
            bottom: 80,
            right: -80,
            size: 180,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          _buildShape(
            top: 250,
            left: -60,
            size: 150,
            color: AppColors.red.withValues(alpha: 0.12),
          ),

         /* Stack(
            children: _buildSmallBubbles(0),
          ),*/

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          SafeArea(child: widget.child),
        ],
      ),
    );
  }

  /*List<Widget> _buildSmallBubbles(double move) {
    return [
      _bubble(
        top: 12 + move,
        left: 12,
        size: 6,
        color: AppColors.primary,
      ),
      _bubble(
        top: 42,
        left: 70 + move,
        size: 4,
        color: AppColors.yellow,
        opacity: 0.38,
      ),
      _bubble(
        top: 30 + move,
        right: 42,
        size: 10,
        color: AppColors.pink,
        opacity: 0.38,
      ),
      _bubble(
        top: 75,
        right: 18 + move,
        size: 6,
        color: AppColors.secondary,
        opacity: 0.38,
      ),
      _bubble(
        top: 95 - move,
        left: 18,
        size: 5,
        color: AppColors.red,
        opacity: 0.38,
      ),

      _bubble(
        top: 170,
        left: 10 + move,
        size: 13,
        color: AppColors.secondary,
      ),
      _bubble(
        top: 250 + move,
        left: 24,
        size: 5,
        color: AppColors.primary,
        opacity: 0.38,
      ),
      _bubble(
        top: 340,
        left: 8 + move,
        size: 8,
        color: AppColors.pink,
      ),
      _bubble(
        bottom: 190 + move,
        left: 22,
        size: 4,
        color: AppColors.yellow,
        opacity: 0.38,
      ),
      _bubble(
        bottom: 95,
        left: 14 + move,
        size: 11,
        color: AppColors.red,
      ),

      _bubble(
        top: 150 + move,
        right: 14,
        size: 6,
        color: AppColors.yellow,
      ),
      _bubble(
        top: 235,
        right: 24 + move,
        size: 14,
        color: AppColors.secondary,
      ),
      _bubble(
        top: 330 - move,
        right: 10,
        size: 4,
        color: AppColors.primary,
        opacity: 0.38,
      ),
      _bubble(
        bottom: 185,
        right: 18 + move,
        size: 8,
        color: AppColors.pink,
      ),
      _bubble(
        bottom: 90 + move,
        right: 30,
        size: 12,
        color: AppColors.secondary,
      ),

      _bubble(
        bottom: 28,
        left: 45 + move,
        size: 5,
        color: AppColors.primary,
      ),
      _bubble(
        bottom: 42 + move,
        left: 105,
        size: 11,
        color: AppColors.pink,
      ),
      _bubble(
        bottom: 20,
        right: 80 + move,
        size: 4,
        color: AppColors.yellow,
        opacity: 0.38,
      ),
      _bubble(
        bottom: 55 - move,
        right: 34,
        size: 9,
        color: AppColors.red,
      ),
      _bubble(
        bottom: 18,
        right: 145 + move,
        size: 13,
        color: AppColors.secondary,
      ),

      _bubble(
        top: 220 + move,
        left: 90,
        size: 6,
        color: AppColors.primary,
        opacity: 0.38,
      ),
      _bubble(
        top: 260,
        right: 110 + move,
        size: 5,
        color: AppColors.yellow,
        opacity: 0.38,
      ),
      _bubble(
        top: 300 - move,
        left: 120,
        size: 8,
        color: AppColors.pink,
        opacity: 0.38,
      ),
      _bubble(
        top: 280,
        right: 70 + move,
        size: 4,
        color: AppColors.secondary,
        opacity: 0.38,
      ),
      _bubble(
        top: 240 + move,
        left: 160,
        size: 7,
        color: AppColors.red,
        opacity: 0.38,
      ),
    ];
  }

  Widget _bubble({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    double opacity = 0.55,
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
          color: color.withValues(alpha: opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }*/

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