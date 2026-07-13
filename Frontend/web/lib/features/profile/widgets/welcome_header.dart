// lib/features/profile/widgets/welcome_header.dart
import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  final String? userName;

  const WelcomeHeader({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    final name = userName ?? 'Explorer';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D4059),
            const Color(0xFF3B5A7A).withOpacity(0.8), // ✅ FIXED: withOpacity
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), // ✅ FIXED: withOpacity
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2), // ✅ FIXED: withOpacity
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $name!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your learning journey continues',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7), // ✅ FIXED: withOpacity
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}