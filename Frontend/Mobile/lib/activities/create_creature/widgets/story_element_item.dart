import 'package:flutter/material.dart';

class StoryElementItem extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Widget icon;
  final bool missing;

  const StoryElementItem({
    super.key,
    required this.label,
    required this.bgColor,
    required this.icon,
    this.missing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: missing ? Colors.redAccent : Colors.transparent,
              width: 3,
            ),
          ),
          child: icon,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: missing ? Colors.redAccent : Colors.black87,
          ),
        ),
      ],
    );
  }
}