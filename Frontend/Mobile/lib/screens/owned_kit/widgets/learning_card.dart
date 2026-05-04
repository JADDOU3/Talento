import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'primary_button.dart';

enum LearningCardType {
  active,
  challenge,
}

class LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final LearningCardType type;
  final String? buttonText;
  final VoidCallback? onPressed;

  const LearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    this.buttonText,
    this.onPressed,
  });

  bool get isChallenge => type == LearningCardType.challenge;

  Color get backgroundColor =>
      isChallenge ? const Color(0xFFFFF5F8) : const Color(0xFFEFFFFA);

  Color get accentColor => isChallenge ? AppColors.pink : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isChallenge ? 18 : 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withOpacity(isChallenge ? 0.26 : 0.10),
          width: isChallenge ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isChallenge ? _challengeLayout() : _activeLayout(),
    );
  }

  Widget _activeLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconBubble(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _smallLabel('نشاط حالي'),
              const SizedBox(height: 5),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: accentColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 13,
          ),
        ),
      ],
    );
  }

  Widget _challengeLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _iconBubble(),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _smallLabel('مهمة قادمة'),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.65,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: PrimaryButton(
            text: buttonText ?? 'ابدأ الآن',
            onPressed: onPressed,
            width: 126,
            height: 42,
          ),
        ),
      ],
    );
  }

  Widget _iconBubble() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.13),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: accentColor,
        size: 22,
      ),
    );
  }

  Widget _smallLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontSize: 11,
        color: accentColor,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
