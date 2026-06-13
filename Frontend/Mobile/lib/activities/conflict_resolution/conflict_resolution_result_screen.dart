import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/button.dart';

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
    final title = isFinalComplete
        ? 'رائع جدًا!'
        : isCorrect
        ? 'إجابة صحيحة!'
        : 'جرّبي مرة أخرى';

    final subtitle = isFinalComplete
        ? 'لقد أكملتِ نشاط حلّ النزاعات بنجاح.'
        : isCorrect
        ? 'اختيار ممتاز، لننتقل للتحدي التالي.'
        : 'لا بأس، اختاري بطاقة أخرى وامسحي رمز QR من جديد.';

    final emoji = isFinalComplete
        ? '🎉'
        : isCorrect
        ? '✅'
        : '🔁';

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
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
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
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                  ),
                  if (elapsed != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'الوقت: ${elapsed!.inSeconds} ثانية',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  if (!isCorrect && onTryAgain != null)
                    ActivityTemplateButton(
                      text: 'أعيد المحاولة',
                      backgroundColor: AppColors.primary,
                      height: 64,
                      fontSize: 24,
                      onPressed: onTryAgain!,
                    ),
                  if (isFinalComplete && onDone != null)
                    ActivityTemplateButton(
                      text: 'رجوع',
                      backgroundColor: AppColors.primary,
                      height: 64,
                      fontSize: 24,
                      onPressed: onDone!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}