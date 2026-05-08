import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AuthSwitchText extends StatelessWidget {
  final String questionText;
  final String actionText;
  final VoidCallback onTap;

  const AuthSwitchText({
    super.key,
    required this.questionText,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: TextDirection.rtl,
      children: [
        Text(
          questionText,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}