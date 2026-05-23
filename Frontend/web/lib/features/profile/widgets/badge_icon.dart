import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({
    super.key,
    required this.color,
    this.icon,
    this.isPlaceholder = false,
  });

  final Color color;
  final IconData? icon;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isPlaceholder ? const Color(0xFFE0E0E0) : color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isPlaceholder
          ? Icon(Icons.lock_outline, color: Colors.grey.shade500, size: 22)
          : Icon(
              icon ?? Icons.emoji_events_rounded,
              color: Colors.white,
              size: 26,
            ),
    );
  }
}
