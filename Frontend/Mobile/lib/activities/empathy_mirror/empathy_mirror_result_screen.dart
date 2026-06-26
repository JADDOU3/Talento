import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/app_background.dart';

/// Result screen for Levels 1, 4, 5 and Level 2 final.
/// Correct → auto-advance. Wrong → shows "Try Again" button.
class EmpathyMirrorResultScreen extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onNext;

  const EmpathyMirrorResultScreen({
    super.key,
    required this.isCorrect,
    required this.onNext,
  });

  @override
  State<EmpathyMirrorResultScreen> createState() =>
      _EmpathyMirrorResultScreenState();
}

class _EmpathyMirrorResultScreenState
    extends State<EmpathyMirrorResultScreen> {
  Timer? _autoClose;

  @override
  void initState() {
    super.initState();
    if (widget.isCorrect) {
      _autoClose =
          Timer(const Duration(milliseconds: 2000), widget.onNext);
    }
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.isCorrect;
    final emoji = correct ? '🌟' : '🤔';
    final title = correct ? 'أحسنت!' : 'تقريبًا!';
    final subtitle = correct
        ? 'فهمت شعور الشخصية بشكل رائع'
        : 'حاول مرة أخرى وفكّر جيدًا';
    final accent = correct ? AppColors.primary : AppColors.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (_, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.25),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 64)),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: accent,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!correct) ...[
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'حاول مرة أخرى',
                            style: AppTextStyles.button.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
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
