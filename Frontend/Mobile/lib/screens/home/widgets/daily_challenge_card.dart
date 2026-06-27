import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/home/daily_challenge_model.dart';

class DailyChallengeCard extends StatelessWidget {
  final DailyChallengeModel challenge;
  final bool challengeAnswered;
  final bool challengeCorrect;
  final String? correctAnswer;
  final bool isSubmitting;
  final String? submittingAnswer;
  final ValueChanged<String> onAnswerSelected;

  const DailyChallengeCard({
    super.key,
    required this.challenge,
    required this.challengeAnswered,
    required this.challengeCorrect,
    required this.correctAnswer,
    required this.isSubmitting,
    required this.submittingAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.pink.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: challengeAnswered ? _buildResultContent() : _buildQuestionContent(),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(
          title: 'تحدي اليوم 🌟',
          icon: Icons.star_rounded,
          iconColor: AppColors.yellow,
        ),
        const SizedBox(height: 14),
        Text(
          challenge.question,
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.55,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: challenge.choices.map((choice) {
            final isTappedButton = isSubmitting && submittingAnswer == choice;

            return _ChoiceButton(
              text: choice,
              isLoading: isTappedButton,
              isDisabled: isSubmitting,
              onTap: () => onAnswerSelected(choice),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultContent() {
    final answerText = correctAnswer?.trim().isNotEmpty == true
        ? correctAnswer!.trim()
        : 'غير متوفر';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (challengeCorrect)
          _buildTitleRow(
            title: 'أحسنت! ✅',
            icon: Icons.check_circle_rounded,
            iconColor: AppColors.success,
          )
        else
          _buildTitleRow(
            title: 'حاول مرة أخرى غداً ❌',
            icon: Icons.cancel_rounded,
            iconColor: AppColors.error,
          ),
        const SizedBox(height: 10),
        if (challengeCorrect)
          Text(
            'إجابتك صحيحة',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        const SizedBox(height: 14),
        Text(
          challenge.question,
          textAlign: TextAlign.right,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.55,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: challengeCorrect
                ? AppColors.success.withValues(alpha: 0.10)
                : AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: challengeCorrect
                  ? AppColors.success.withValues(alpha: 0.25)
                  : AppColors.error.withValues(alpha: 0.20),
            ),
          ),
          child: Text(
            challengeCorrect
                ? '✅ $answerText'
                : 'الإجابة الصحيحة: $answerText',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              color: challengeCorrect ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w800,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleRow({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontSize: 17,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.text,
    required this.isLoading,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.white.withValues(alpha: 0.65),
          foregroundColor: AppColors.pink,
          disabledForegroundColor: AppColors.pink.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: AppColors.pink.withValues(alpha: 0.28),
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 17,
          height: 17,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.pink,
          ),
        )
            : Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.pink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}