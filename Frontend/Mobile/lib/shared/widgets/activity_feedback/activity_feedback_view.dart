import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum ActivityFeedbackType {
  correct,
  wrong,
}

class ActivityFeedbackView extends StatelessWidget {
  final ActivityFeedbackType type;

  final String? title;
  final String? subtitle;
  final String? cardTitle;
  final String? message;
  final String? primaryButtonText;

  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSecondaryPressed;

  final String secondaryButtonText;
  final IconData secondaryButtonIcon;

  const ActivityFeedbackView({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.cardTitle,
    this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.onHomePressed,
    this.onSecondaryPressed,
    this.secondaryButtonText = 'إعادة النشاط',
    this.secondaryButtonIcon = Icons.refresh_rounded,
  });

  bool get _isCorrect => type == ActivityFeedbackType.correct;

  Color get _accentColor =>
      _isCorrect ? AppColors.success : AppColors.error;

  Color get _softAccentColor =>
      _isCorrect
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.pink.withValues(alpha: 0.12);

  String get _mascotAssetPath => _isCorrect
      ? 'assets/images/activity_feedback/feedback_correct_mascot.png'
      : 'assets/images/activity_feedback/feedback_wrong_mascot.png';

  String get _resolvedTitle =>
      title ?? (_isCorrect ? 'أحسنت!' : 'قريب جدًا!');

  String get _resolvedSubtitle =>
      subtitle ??
          (_isCorrect
              ? 'إجابة رائعة'
              : 'فكّر مرة أخرى وحاول من جديد');

  String get _resolvedCardTitle =>
      cardTitle ??
          (_isCorrect
              ? 'واصل التقدّم!'
              : 'لا تستسلم!');

  String get _resolvedMessage =>
      message ??
          (_isCorrect
              ? 'لننتقل إلى التحدّي التالي.'
              : 'كل محاولة تقرّبك من الإجابة الصحيحة.');

  String get _resolvedPrimaryButtonText =>
      primaryButtonText ??
          (_isCorrect ? 'التالي' : 'حاول مرة أخرى');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: _FeedbackBackground(
                isCorrect: _isCorrect,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mascotHeight =
                  (constraints.maxHeight * 0.31).clamp(180.0, 270.0);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 42,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _resolvedTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'DGAgnadeen',
                              color: _accentColor,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _resolvedSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'ArialRounded',
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              width: mascotHeight,
                              height: mascotHeight,
                              decoration: BoxDecoration(
                                color: _softAccentColor,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    _mascotAssetPath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) {
                                      return Icon(
                                        _isCorrect
                                            ? Icons.celebration_rounded
                                            : Icons.psychology_alt_rounded,
                                        color: _accentColor,
                                        size: 96,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, -12),
                            child: _FeedbackCard(
                              accentColor: _accentColor,
                              title: _resolvedCardTitle,
                              message: _resolvedMessage,
                              primaryButtonText:
                              _resolvedPrimaryButtonText,
                              isCorrect: _isCorrect,
                              onPrimaryPressed: onPrimaryPressed,
                            ),
                          ),
                          if (onHomePressed != null ||
                              onSecondaryPressed != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (onHomePressed != null)
                                  _SmallActionButton(
                                    icon: Icons.home_rounded,
                                    label: 'الرئيسية',
                                    accentColor: _accentColor,
                                    onPressed: onHomePressed!,
                                  ),
                                if (onHomePressed != null &&
                                    onSecondaryPressed != null)
                                  const SizedBox(width: 38),
                                if (onSecondaryPressed != null)
                                  _SmallActionButton(
                                    icon: secondaryButtonIcon,
                                    label: secondaryButtonText,
                                    accentColor: _accentColor,
                                    onPressed: onSecondaryPressed!,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final Color accentColor;
  final String title;
  final String message;
  final String primaryButtonText;
  final bool isCorrect;
  final VoidCallback? onPrimaryPressed;

  const _FeedbackCard({
    required this.accentColor,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.isCorrect,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              isCorrect ? Icons.check_rounded : Icons.close_rounded,
              color: AppColors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DGAgnadeen',
              color: accentColor,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ArialRounded',
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
          if (onPrimaryPressed != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: onPrimaryPressed,
                icon: Icon(
                  isCorrect
                      ? Icons.arrow_back_rounded
                      : Icons.refresh_rounded,
                ),
                label: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: AppColors.white,
                  elevation: 3,
                  shadowColor: accentColor.withValues(alpha: 0.28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onPressed;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.white,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: AppColors.black.withValues(alpha: 0.12),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(
                icon,
                color: accentColor,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'ArialRounded',
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FeedbackBackground extends StatelessWidget {
  final bool isCorrect;

  const _FeedbackBackground({
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
    isCorrect ? AppColors.background : const Color(0xFFFFF8FA);

    final bubbleColor =
    isCorrect ? AppColors.secondary : AppColors.pink;

    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        children: [
          Positioned(
            top: -70,
            left: -55,
            child: _SoftBubble(
              size: 190,
              color: bubbleColor.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: 65,
            right: -68,
            child: _SoftBubble(
              size: 180,
              color: AppColors.pink.withValues(alpha: 0.11),
            ),
          ),
          Positioned(
            bottom: 45,
            left: -48,
            child: _SoftBubble(
              size: 160,
              color: AppColors.yellow.withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: 130,
            right: -60,
            child: _SoftBubble(
              size: 150,
              color: AppColors.secondary.withValues(alpha: 0.11),
            ),
          ),
          if (isCorrect) ...[
            const Positioned(
              top: 115,
              left: 44,
              child: Icon(
                Icons.star_rounded,
                color: AppColors.yellow,
                size: 25,
              ),
            ),
            const Positioned(
              top: 190,
              right: 48,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const Positioned(
              top: 300,
              left: 35,
              child: Icon(
                Icons.circle,
                color: AppColors.pink,
                size: 12,
              ),
            ),
          ] else ...[
            Positioned(
              top: 165,
              left: 42,
              child: Icon(
                Icons.circle,
                color: AppColors.pink.withValues(alpha: 0.22),
                size: 18,
              ),
            ),
            Positioned(
              top: 250,
              right: 42,
              child: Icon(
                Icons.circle,
                color: AppColors.red.withValues(alpha: 0.14),
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SoftBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
