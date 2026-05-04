import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String assetPath;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.text,
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.secondary.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}