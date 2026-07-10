import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'button.dart';
import 'mascot.dart';

class ActivityIntroTemplate extends StatelessWidget {
  final Widget background;
  final String mascotAssetPath;

  final String startButtonText;
  final String replayButtonText;

  final VoidCallback onStartPressed;
  final VoidCallback onReplayPressed;

  final Color? startButtonColor;
  final Color? replayButtonColor;

  final Alignment mascotAlignment;
  final double mascotWidthFactor;

  const ActivityIntroTemplate({
    super.key,
    required this.background,
    required this.mascotAssetPath,
    required this.onStartPressed,
    required this.onReplayPressed,
    this.startButtonText = 'ابدأ التجربة',
    this.replayButtonText = 'اسمع الشرح مرة أخرى',
    this.startButtonColor,
    this.replayButtonColor,
    this.mascotAlignment = Alignment.bottomRight,
    this.mascotWidthFactor = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: background),

            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 12,
                        right: 0,
                        child: _BackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),

                      Positioned(
                        top: screenHeight * 0.25,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            ActivityTemplateButton(
                              text: startButtonText,
                              onPressed: onStartPressed,
                              backgroundColor:
                              startButtonColor ?? AppColors.primary,
                              height: 82,
                              borderRadius: 30,
                              fontSize: screenWidth * 0.09,
                              textStyle: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.white,
                                fontFamily: 'DGAgnadeen',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.035),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.07,
                              ),
                              child: ActivityTemplateButton(
                                text: replayButtonText,
                                onPressed: onReplayPressed,
                                backgroundColor:
                                replayButtonColor ?? AppColors.pink,
                                height: 62,
                                borderRadius: 28,
                                fontSize: screenWidth * 0.042,
                                textStyle: AppTextStyles.button.copyWith(
                                  color: AppColors.white,
                                  fontFamily: 'DGAgnadeen',
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Align(
                        alignment: mascotAlignment,
                        child: Transform.translate(
                          offset: const Offset(45, 15),
                          child: ActivityMascot(
                            assetPath: mascotAssetPath,
                            width: screenWidth * mascotWidthFactor,
                            animateFloat: true,
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
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}