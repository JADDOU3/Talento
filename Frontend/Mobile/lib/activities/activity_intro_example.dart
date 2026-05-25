import 'package:flutter/material.dart';

import '../shared/widgets/activity_template/activity_intro_template.dart';

class ActivityIntroExampleScreen extends StatelessWidget {
  const ActivityIntroExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivityIntroTemplate(
      background: const _ScienceActivityBackground(),
      mascotAssetPath: 'assets/images/template_mascot.png',
      onStartPressed: () {
        debugPrint('Start activity pressed');
      },
      onReplayPressed: () {
        debugPrint('Replay explanation pressed');
      },
    );
  }
}

class _ScienceActivityBackground extends StatelessWidget {
  const _ScienceActivityBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: const [
          _CircleDecoration(
            top: -30,
            left: -25,
            size: 90,
            color: Color(0xFFCBEFF5),
          ),
          _CircleDecoration(
            top: 70,
            right: -35,
            size: 110,
            color: Color(0xFFF6CBD8),
          ),
          _CircleDecoration(
            bottom: 130,
            left: -35,
            size: 100,
            color: Color(0xFFF6CBD8),
          ),
          _ScienceIcon(top: 36, right: 70, text: '⚗️', size: 28),
          _ScienceIcon(top: 105, left: 80, text: '🧪', size: 30),
          _ScienceIcon(top: 185, right: 80, text: '🔬', size: 34),
          _ScienceIcon(top: 255, left: 30, text: '⭐', size: 32),
          _ScienceIcon(top: 380, right: 45, text: '🧪', size: 28),
          _ScienceIcon(bottom: 220, left: 45, text: '🔬', size: 32),
          _ScienceIcon(bottom: 105, right: 70, text: '⚗️', size: 26),
          _ScienceIcon(bottom: 55, left: 85, text: '🧬', size: 28),
        ],
      ),
    );
  }
}

class _CircleDecoration extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  const _CircleDecoration({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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

class _ScienceIcon extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final String text;
  final double size;

  const _ScienceIcon({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.text,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Text(
        text,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}