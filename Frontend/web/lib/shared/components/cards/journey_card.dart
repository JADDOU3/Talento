import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

class JourneyCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor; // 🔥 مهم

  const JourneyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Column(
        children: [
          // 🔥 ICON BOX
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: widget.iconColor.withOpacity(
                    isHovered ? 0.4 : 0.25,
                  ),
                  blurRadius: isHovered ? 40 : 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            widget.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}