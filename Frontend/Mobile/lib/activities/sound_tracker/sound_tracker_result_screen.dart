import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/app_background.dart';

class SoundTrackerResultScreen extends StatelessWidget {
  final bool isCorrect;
  final int levelNumber;
  final int totalLevels;
  final bool isLastLevel;
  final String message;
  final VoidCallback onRetryPressed;
  final VoidCallback onContinuePressed;

  const SoundTrackerResultScreen({
    super.key,
    required this.isCorrect,
    required this.levelNumber,
    required this.totalLevels,
    required this.isLastLevel,
    required this.message,
    required this.onRetryPressed,
    required this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.success : AppColors.error;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: color.withOpacity(0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(color),
                    const SizedBox(height: 22),
                    _buildLevelBadge(color),
                    const SizedBox(height: 18),
                    Text(
                      isCorrect ? 'أحسنت!' : 'حاول مرة أخرى',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 17,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (isCorrect)
                      _buildPrimaryButton(
                        label: isLastLevel ? 'إنهاء النشاط' : 'المستوى التالي',
                        icon: isLastLevel
                            ? Icons.celebration_rounded
                            : Icons.arrow_back_rounded,
                        onPressed: onContinuePressed,
                      )
                    else
                      _buildPrimaryButton(
                        label: 'أعيد المحاولة',
                        icon: Icons.replay_rounded,
                        onPressed: onRetryPressed,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.70, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        width: 116,
        height: 116,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.26),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Icon(
          isCorrect ? Icons.check_rounded : Icons.close_rounded,
          color: AppColors.white,
          size: 72,
        ),
      ),
    );
  }

  Widget _buildLevelBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Text(
        'المستوى $levelNumber من $totalLevels',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isCorrect ? AppColors.success : AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 5,
          shadowColor: AppColors.primary.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class SoundTrackerActivityCompleteScreen extends StatefulWidget {
  final Future<void> Function(BuildContext context) onReplayPressed;
  final VoidCallback onBackToRoadmapPressed;

  const SoundTrackerActivityCompleteScreen({
    super.key,
    required this.onReplayPressed,
    required this.onBackToRoadmapPressed,
  });

  @override
  State<SoundTrackerActivityCompleteScreen> createState() =>
      _SoundTrackerActivityCompleteScreenState();
}

class _SoundTrackerActivityCompleteScreenState
    extends State<SoundTrackerActivityCompleteScreen> {
  bool _isRestarting = false;

  Future<void> _handleReplay() async {
    if (_isRestarting) return;

    setState(() {
      _isRestarting = true;
    });

    try {
      await widget.onReplayPressed(context);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isRestarting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر إعادة النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.70, end: 1),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.yellow.withOpacity(0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          color: AppColors.white,
                          size: 72,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'رائع جدًا!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'لقد أنهيت نشاط تتبّع الأصوات بنجاح.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 18,
                        height: 1.45,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isRestarting ? null : _handleReplay,
                        icon: _isRestarting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: AppColors.white,
                          ),
                        )
                            : const Icon(Icons.replay_rounded),
                        label: Text(
                          _isRestarting
                              ? 'جاري الإعادة...'
                              : 'إعادة من البداية',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.border,
                          foregroundColor: AppColors.white,
                          elevation: 5,
                          shadowColor: AppColors.primary.withOpacity(0.25),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: AppTextStyles.button.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: _isRestarting
                            ? null
                            : widget.onBackToRoadmapPressed,
                        icon: const Icon(Icons.map_rounded),
                        label: const Text('العودة للخريطة'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withOpacity(0.35),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: AppTextStyles.button.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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