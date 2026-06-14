import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/layout/app_background.dart';

class ConflictResolutionResultScreen extends StatelessWidget {
  final bool isCorrect;
  final bool isFinalComplete;
  final Duration? elapsed;
  final VoidCallback? onTryAgain;
  final VoidCallback? onDone;

  const ConflictResolutionResultScreen({
    super.key,
    required this.isCorrect,
    this.isFinalComplete = false,
    this.elapsed,
    this.onTryAgain,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = isFinalComplete
        ? '🎉'
        : isCorrect
        ? '✅'
        : '🔁';

    final title = isFinalComplete
        ? 'أحسنت!'
        : isCorrect
        ? 'إجابة صحيحة!'
        : 'حاولي مرة أخرى';

    final subtitle = isFinalComplete
        ? 'لقد أكملتِ نشاط حل النزاعات!'
        : isCorrect
        ? 'اختيار رائع، لنكمل التحدي التالي.'
        : 'لا بأس، اختاري بطاقة أخرى وامسحي رمز QR من جديد.';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.yellow.withValues(alpha: 0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'DGAgnadeen',
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 21,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (elapsed != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        'الوقت: ${_formatDuration(elapsed!)}',
                        style: const TextStyle(
                          fontFamily: 'ArialRounded',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 42),
                  if (!isCorrect && onTryAgain != null)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onTryAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'أعيد المحاولة',
                          style: TextStyle(
                            fontFamily: 'DGAgnadeen',
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (isFinalComplete && onDone != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'العودة للخريطة',
                          style: TextStyle(
                            fontFamily: 'DGAgnadeen',
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
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
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}