import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../audio/voice_over_controller.dart';
import 'button.dart';
import 'mascot.dart';

class ActivityIntroTemplate extends StatefulWidget {
  final Widget background;
  final String mascotAssetPath;
  final int? activityId;

  final String startButtonText;
  final String replayButtonText;

  final VoidCallback onStartPressed;

  /// Kept as a fallback for examples or screens that do not have an activityId.
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
    this.activityId,
    this.startButtonText = 'ابدأ التجربة',
    this.replayButtonText = 'اسمع الشرح مرة أخرى',
    this.startButtonColor,
    this.replayButtonColor,
    this.mascotAlignment = Alignment.bottomRight,
    this.mascotWidthFactor = 0.75,
  });

  @override
  State<ActivityIntroTemplate> createState() =>
      _ActivityIntroTemplateState();
}

class _ActivityIntroTemplateState extends State<ActivityIntroTemplate> {
  final VoiceOverController _voiceOverController =
  VoiceOverController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playIntroVoiceOver();
    });
  }

  @override
  void didUpdateWidget(covariant ActivityIntroTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activityId != widget.activityId) {
      _playIntroVoiceOver();
    }
  }

  Future<void> _playIntroVoiceOver() async {
    final activityId = widget.activityId;

    if (activityId == null || activityId <= 0) {
      return;
    }

    await _voiceOverController.playIntro(
      activityId: activityId,
    );
  }

  Future<void> _handleStartPressed() async {
    await _voiceOverController.stop();

    if (!mounted) return;

    widget.onStartPressed();
  }

  Future<void> _handleReplayPressed() async {
    final activityId = widget.activityId;

    if (activityId == null || activityId <= 0) {
      widget.onReplayPressed();
      return;
    }

    await _playIntroVoiceOver();
  }

  Future<void> _handleBackPressed() async {
    await _voiceOverController.stop();

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _voiceOverController.dispose();
    super.dispose();
  }

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
            Positioned.fill(child: widget.background),
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
                          onTap: _handleBackPressed,
                        ),
                      ),
                      Positioned(
                        top: screenHeight * 0.25,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            ActivityTemplateButton(
                              text: widget.startButtonText,
                              onPressed: _handleStartPressed,
                              backgroundColor:
                              widget.startButtonColor ??
                                  AppColors.primary,
                              height: 82,
                              borderRadius: 30,
                              fontSize: screenWidth * 0.09,
                              textStyle:
                              AppTextStyles.headlineLarge.copyWith(
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
                                text: widget.replayButtonText,
                                onPressed: _handleReplayPressed,
                                backgroundColor:
                                widget.replayButtonColor ??
                                    AppColors.pink,
                                height: 62,
                                borderRadius: 28,
                                fontSize: screenWidth * 0.042,
                                textStyle:
                                AppTextStyles.button.copyWith(
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
                        alignment: widget.mascotAlignment,
                        child: Transform.translate(
                          offset: const Offset(45, 15),
                          child: ActivityMascot(
                            assetPath: widget.mascotAssetPath,
                            width:
                            screenWidth * widget.mascotWidthFactor,
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
