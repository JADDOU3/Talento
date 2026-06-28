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

  static const String _challengeMascotPath =
      'assets/images/mascot_challenge_star.png';

  static const String _successMascotPath =
      'assets/images/mascot_challenge_success.png';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: !challengeAnswered
          ? _buildQuestionCard()
          : challengeCorrect
          ? _buildSuccessCard()
          : _buildWrongCard(),
    );
  }

  Widget _buildQuestionCard() {
    final choices = challenge.choices.take(3).toList();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 21),
          padding: const EdgeInsets.fromLTRB(14, 39, 14, 15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFEFD),
                Color(0xFFFFF7F9),
                Color(0xFFFFFCF5),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFA9BA).withValues(alpha: 0.58),
              width: 1.25,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.055),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.70),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                bottom: 14,
                right: 22,
                child: _SparkleDot(
                  color: Color(0xFF76DCD5),
                  size: 6,
                ),
              ),
              _buildQuestionBody(choices),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          child: _SoftRibbon(
            title: 'تحدي اليوم',
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBody(List<String> choices) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            top: 9,
            child: _MascotImage(
              assetPath: _challengeMascotPath,
              width: 90,
              fallbackColor: AppColors.pink,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 88),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                Text(
                  challenge.question,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    height: 1.5,
                    fontSize: 16.4,
                  ),
                ),
                const SizedBox(height: 19),
                Row(
                  children: List.generate(choices.length, (index) {
                    final choice = choices[index];
                    final isTappedButton =
                        isSubmitting && submittingAnswer == choice;

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: index == 0 ? 0 : 7,
                        ),
                        child: _ChoiceButton(
                          text: choice,
                          isLoading: isTappedButton,
                          isDisabled: isSubmitting,
                          onTap: () => onAnswerSelected(choice),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    final answerText = correctAnswer?.trim().isNotEmpty == true
        ? correctAnswer!.trim()
        : 'غير متوفر';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.fromLTRB(16, 38, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFEF8),
                Color(0xFFFFF8E8),
                Color(0xFFFFFCF3),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFF4D88A).withValues(alpha: 0.72),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF4D88A).withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.80),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: 10,
                right: 18,
                child: _TinySparkle(
                  color: Color(0xFFF5C85C),
                  size: 15,
                ),
              ),
              const Positioned(
                top: 42,
                right: 36,
                child: _TinySparkle(
                  color: Color(0xFFFFD98A),
                  size: 10,
                ),
              ),
              const Positioned(
                bottom: 18,
                right: 20,
                child: _TinySparkle(
                  color: Color(0xFFFFC86C),
                  size: 11,
                ),
              ),
              const Positioned(
                bottom: 14,
                left: 22,
                child: _SparkleDot(
                  color: Color(0xFFF6D77C),
                  size: 7,
                ),
              ),
              Positioned(
                bottom: -24,
                right: -18,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFC2).withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -28,
                left: -22,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D9).withValues(alpha: 0.36),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -4,
                      top: 4,
                      child: _MascotImage(
                        assetPath: _successMascotPath,
                        width: 120,
                        fallbackColor: const Color(0xFFE0B84D),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 92),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'أحسنت!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: const Color(0xFFB98A17),
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'إجابتك صحيحة',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFFCC9D29),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.8,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            challenge.question,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              height: 1.5,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 210,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: const Color(0xFFF2D37E)
                                        .withValues(alpha: 0.75),
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF2D37E)
                                          .withValues(alpha: 0.10),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFFD6A628),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        answerText,
                                        textAlign: TextAlign.center,
                                        style:
                                        AppTextStyles.bodyMedium.copyWith(
                                          color: const Color(0xFFB98A17),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          child: _SoftRibbon(
            title: 'تحدي اليوم',
          ),
        ),
      ],
    );
  }


  Widget _buildWrongCard() {
    final answerText = correctAnswer?.trim().isNotEmpty == true
        ? correctAnswer!.trim()
        : 'غير متوفر';

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.fromLTRB(16, 38, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFFCFC),
                Color(0xFFFFF1F3),
                Color(0xFFFFFBF5),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFA9BA).withValues(alpha: 0.52),
              width: 1.25,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.80),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: 10,
                right: 18,
                child: _TinySparkle(
                  color: Color(0xFFFFA0B3),
                  size: 14,
                ),
              ),
              const Positioned(
                top: 44,
                right: 38,
                child: _TinySparkle(
                  color: Color(0xFFFFC64B),
                  size: 10,
                ),
              ),
              const Positioned(
                bottom: 16,
                right: 22,
                child: _SparkleDot(
                  color: Color(0xFF76DCD5),
                  size: 6,
                ),
              ),
              Positioned(
                bottom: -24,
                right: -18,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.pink.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -28,
                left: -22,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.035),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -4,
                      top: 6,
                      child: _MascotImage(
                        assetPath: _challengeMascotPath,
                        width: 98,
                        fallbackColor: AppColors.error,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'حاول مرة أخرى غدًا',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'كل محاولة تقرّبك من الإجابة',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.68),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            challenge.question,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              height: 1.5,
                              fontSize: 15.7,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 230,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppColors.error.withValues(alpha: 0.18),
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.error.withValues(alpha: 0.055),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lightbulb_rounded,
                                      color: AppColors.error.withValues(alpha: 0.82),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 7),
                                    Flexible(
                                      child: Text(
                                        'الإجابة الصحيحة: $answerText',
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13.7,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: 0,
          child: _SoftRibbon(
            title: 'تحدي اليوم',
          ),
        ),
      ],
    );
  }


}

class _SoftRibbon extends StatelessWidget {
  final String title;

  const _SoftRibbon({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            right: -16,
            child: Container(
              width: 38,
              height: 25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF94AA),
                    Color(0xFFFFB2C1),
                  ],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Positioned(
            left: -16,
            child: Container(
              width: 38,
              height: 25,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFB2C1),
                    Color(0xFFFF94AA),
                  ],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Container(
            height: 41,
            padding: const EdgeInsets.symmetric(horizontal: 27),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF7896),
                  Color(0xFFFF9CAF),
                  Color(0xFFFF7896),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.90),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.20),
                  blurRadius: 13,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.white,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.white,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
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
      height: 44,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: AppColors.white.withValues(alpha: 0.96),
          disabledBackgroundColor: AppColors.white.withValues(alpha: 0.62),
          foregroundColor: AppColors.pink,
          disabledForegroundColor: AppColors.pink.withValues(alpha: 0.55),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.36),
              width: 1.15,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.84),
            fontWeight: FontWeight.w900,
            fontSize: 13.2,
          ),
        ),
      ),
    );
  }
}

class _MascotImage extends StatelessWidget {
  final String assetPath;
  final double width;
  final Color fallbackColor;

  const _MascotImage({
    required this.assetPath,
    required this.width,
    required this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: width,
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) {
            return Icon(
              Icons.smart_toy_rounded,
              color: fallbackColor,
              size: width * 0.50,
            );
          },
        ),
      ),
    );
  }
}

class _TinySparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _TinySparkle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      color: color.withValues(alpha: 0.74),
      size: size,
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final Color color;
  final double size;

  const _SparkleDot({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.78),
        shape: BoxShape.circle,
      ),
    );
  }
}