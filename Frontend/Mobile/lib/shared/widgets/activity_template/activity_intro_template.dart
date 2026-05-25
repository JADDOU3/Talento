import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
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

  final EdgeInsetsGeometry contentPadding;

  const ActivityIntroTemplate({
    super.key,
    required this.background,
    required this.mascotAssetPath,
    required this.onStartPressed,
    required this.onReplayPressed,
    this.startButtonText = 'ابدأ التجربة',
    this.replayButtonText = 'اسمع الشرح مرة اخرى',
    this.startButtonColor,
    this.replayButtonColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 26),
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
          children: [
            Positioned.fill(child: background),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: contentPadding,
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight * 0.12),

                      ActivityTemplateButton(
                        text: startButtonText,
                        onPressed: onStartPressed,
                        backgroundColor:
                        startButtonColor ?? AppColors.primary,
                        height: screenHeight * 0.13,
                        borderRadius: 30,
                        fontSize: screenWidth * 0.105,
                      ),

                      SizedBox(height: screenHeight * 0.05),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.12,
                        ),
                        child: ActivityTemplateButton(
                          text: replayButtonText,
                          onPressed: onReplayPressed,
                          backgroundColor:
                          replayButtonColor ?? AppColors.pink,
                          height: screenHeight * 0.085,
                          borderRadius: 28,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),

                      const Spacer(),

                      ActivityMascot(
                        assetPath: mascotAssetPath,
                        width: screenWidth * 0.78,
                      ),

                      SizedBox(height: screenHeight * 0.03),
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