import 'package:flutter/material.dart';

class StoryElementItem extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Widget icon;

  const StoryElementItem({
    super.key,
    required this.label,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 110,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}