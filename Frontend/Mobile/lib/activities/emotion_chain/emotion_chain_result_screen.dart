import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_cubit.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_state.dart';
import '../../shared/layout/app_background.dart';

/// Result feedback view. Correct auto-advances (driven by the cubit); wrong
/// shows a "Try Again" button that retries the same step.
class EmotionChainResultView extends StatelessWidget {
  final EmotionChainStepResult state;

  const EmotionChainResultView({super.key, required this.state});

  static const Map<String, String> _stepLabels = {
    'feeling': 'المشاعر',
    'action': 'التصرّف',
    'outcome': 'النتيجة',
  };

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.isCorrect;
    final challenge = state.challenge;
    final stepLabel = _stepLabels[challenge.chainStep] ?? challenge.chainStep;
    final color = isCorrect ? AppColors.secondary : AppColors.red;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) =>
                          Transform.scale(scale: scale, child: child),
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCorrect
                              ? Icons.check_rounded
                              : Icons.close_rounded,
                          color: AppColors.white,
                          size: 64,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        stepLabel,
                        style: TextStyle(
                          fontFamily: 'DGAgnadeen',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      isCorrect ? 'أحسنت! إجابة صحيحة' : 'حاول مرّة أخرى',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'DGAgnadeen',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (!isCorrect)
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(22),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: () =>
                                context.read<EmotionChainCubit>().retryStep(),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'حاول مرّة أخرى',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DGAgnadeen',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
