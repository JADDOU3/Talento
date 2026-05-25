import 'package:flutter/material.dart';

class ActivityMascot extends StatelessWidget {
  final String assetPath;
  final double width;
  final BoxFit fit;

  const ActivityMascot({
    super.key,
    required this.assetPath,
    this.width = 360,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      fit: fit,
    );
  }
}