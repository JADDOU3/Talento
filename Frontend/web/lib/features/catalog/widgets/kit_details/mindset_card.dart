import 'package:flutter/material.dart';
import '../../../../util/theme/app_colors.dart';

class MindsetCard extends StatelessWidget {
  const MindsetCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool highlighted;

  static const Color _highlightBg = Color(0xFFFFE4E8);
  static const Color _highlightTitle = Color(0xFF5C1A2E);
  static const Color _highlightBody = Color(0xFF6B3D4A);

  @override
  Widget build(BuildContext context) {
    final titleColor =
        highlighted ? _highlightTitle : AppColors.cartTeal;
    final bodyColor = highlighted ? _highlightBody : AppColors.cartMutedGrey;
    final iconBg = highlighted
        ? const Color(0xFFFFB8C6)
        : AppColors.cartTeal.withValues(alpha: 0.12);
    final iconFg =
        highlighted ? const Color(0xFFB8325A) : AppColors.cartTeal;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: highlighted ? _highlightBg : const Color(0xFFF2EEEA),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconFg, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: titleColor,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              height: 1.55,
              color: bodyColor,
            ),
          ),
        ],
      ),
    );
  }
}
