import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../cubits/coins/coins_cubit.dart';
import '../../layout/app_background.dart';
import '../../layout/animated_background.dart';

enum ActivityFeedbackType {
  correct,
  wrong,
}

class ActivityFeedbackView extends StatelessWidget {
  final ActivityFeedbackType type;
  final String? title;
  final String? cardTitle;
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
    this.cardTitle,
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

  String get _mascotAssetPath => _isCorrect
      ? 'assets/images/activity_feedback/feedback_correct_mascot.png'
      : 'assets/images/activity_feedback/feedback_wrong_mascot.png';

  String get _resolvedTitle =>
      title ?? (_isCorrect ? 'قمت بعملٍ رائع!' : 'اقتربت قليلاً!');

  String get _resolvedCardTitle =>
      cardTitle ?? (_isCorrect ? 'لقد نجحت!' : 'لا تستسلم!');

  String get _resolvedPrimaryButtonText =>
      primaryButtonText ?? (_isCorrect ? 'التالي' : 'لنحاول مرةً أخرى');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox.expand(
        child: _isCorrect
            ? AnimatedBackground(
          child: _CorrectFeedbackLayout(
            title: _resolvedTitle,
            cardTitle: _resolvedCardTitle,
            mascotAssetPath: _mascotAssetPath,
            primaryButtonText: _resolvedPrimaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            onHomePressed: onHomePressed,
            onSecondaryPressed: onSecondaryPressed,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonIcon: secondaryButtonIcon,
          ),
        )
            : AppBackground(
          child: _WrongFeedbackLayout(
            title: _resolvedTitle,
            cardTitle: _resolvedCardTitle,
            mascotAssetPath: _mascotAssetPath,
            primaryButtonText: _resolvedPrimaryButtonText,
            onPrimaryPressed: onPrimaryPressed,
            onHomePressed: onHomePressed,
            onSecondaryPressed: onSecondaryPressed,
            secondaryButtonText: secondaryButtonText,
            secondaryButtonIcon: secondaryButtonIcon,
          ),
        ),
      ),
    );
  }
}

class _CorrectFeedbackLayout extends StatelessWidget {
  final String title;
  final String cardTitle;
  final String mascotAssetPath;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSecondaryPressed;
  final String secondaryButtonText;
  final IconData secondaryButtonIcon;

  const _CorrectFeedbackLayout({
    required this.title,
    required this.cardTitle,
    required this.mascotAssetPath,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.onHomePressed,
    required this.onSecondaryPressed,
    required this.secondaryButtonText,
    required this.secondaryButtonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotSize =
        (constraints.maxHeight * 0.31).clamp(205.0, 280.0).toDouble();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 26),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 38,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SuccessHeader(
                  title: title,
                ),
                const SizedBox(height: 8),
                Center(
                  child: _CelebrationMascot(
                    size: mascotSize,
                    mascotAssetPath: mascotAssetPath,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -24),
                  child: _CorrectFeedbackCard(
                    title: cardTitle,
                    primaryButtonText: primaryButtonText,
                    onPrimaryPressed: onPrimaryPressed,
                  ),
                ),
                if (onHomePressed != null || onSecondaryPressed != null) ...[
                  Transform.translate(
                    offset: const Offset(0, -12),
                    child: _FeedbackActions(
                      onHomePressed: onHomePressed,
                      onSecondaryPressed: onSecondaryPressed,
                      secondaryButtonText: secondaryButtonText,
                      secondaryButtonIcon: secondaryButtonIcon,
                      accentColor: AppColors.success,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SuccessHeader extends StatelessWidget {
  final String title;

  const _SuccessHeader({
    required this.title,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -29,
              bottom: 3,
              child: Transform.rotate(
                angle: 0.35,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.yellow,
                  size: 23,
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DGAgnadeen',
                color: AppColors.primary,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1.05,
                shadows: [
                  Shadow(
                    color: Color(0x2210A896),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CelebrationMascot extends StatelessWidget {
  final double size;
  final String mascotAssetPath;

  const _CelebrationMascot({
    required this.size,
    required this.mascotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 36,
      height: size + 28,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.92),
                  AppColors.secondary.withValues(alpha: 0.18),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
                stops: const [0.12, 0.68, 1],
              ),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.92),
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.79,
            height: size * 0.79,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.10),
                width: 1.5,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.045),
            child: Image.asset(
              mascotAssetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.primary,
                  size: 110,
                );
              },
            ),
          ),
          const Positioned(
            top: 10,
            left: 14,
            child: _FloatingDecoration(
              icon: Icons.star_rounded,
              color: AppColors.yellow,
              size: 31,
              rotation: -0.25,
            ),
          ),
          const Positioned(
            top: 55,
            right: 1,
            child: _FloatingDecoration(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.pink,
              size: 22,
              rotation: 0.22,
            ),
          ),
          const Positioned(
            bottom: 51,
            left: 5,
            child: _FloatingDecoration(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: 20,
              rotation: -0.22,
            ),
          ),
          const Positioned(
            bottom: 25,
            right: 26,
            child: _FloatingDecoration(
              icon: Icons.star_rounded,
              color: AppColors.yellow,
              size: 20,
              rotation: 0.2,
            ),
          ),
          Positioned(
            top: size * 0.45,
            left: 2,
            child: const _ConfettiBar(
              color: AppColors.pink,
              rotation: -0.55,
            ),
          ),
          Positioned(
            top: size * 0.25,
            right: 11,
            child: const _ConfettiBar(
              color: AppColors.primary,
              rotation: 0.62,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingDecoration extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double rotation;

  const _FloatingDecoration({
    required this.icon,
    required this.color,
    required this.size,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Icon(
        icon,
        color: color,
        size: size,
        shadows: const [
          Shadow(
            color: Color(0x22000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _ConfettiBar extends StatelessWidget {
  final Color color;
  final double rotation;

  const _ConfettiBar({
    required this.color,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 9,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _CorrectFeedbackCard extends StatelessWidget {
  final String title;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;

  const _CorrectFeedbackCard({
    required this.title,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 38),
          padding: const EdgeInsets.fromLTRB(22, 57, 22, 22),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 26,
                offset: const Offset(0, 13),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DGAgnadeen',
                  color: AppColors.primary,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.2,
                      color: AppColors.primary.withValues(alpha: 0.11),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.yellow,
                      size: 17,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.2,
                      color: AppColors.primary.withValues(alpha: 0.11),
                    ),
                  ),
                ],
              ),
              if (onPrimaryPressed != null) ...[
                const SizedBox(height: 12),
                _FeedbackPrimaryButton(
                  accentColor: AppColors.primary,
                  label: primaryButtonText,
                  isCorrect: true,
                  onPressed: onPrimaryPressed!,
                ),
              ],
            ],
          ),
        ),
        const _SuccessSeal(),
      ],
    );
  }
}

class _SuccessSeal extends StatelessWidget {
  const _SuccessSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary,
              AppColors.primary,
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.88),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: AppColors.white,
          size: 41,
        ),
      ),
    );
  }
}

class _WrongFeedbackLayout extends StatelessWidget {
  final String title;
  final String cardTitle;
  final String mascotAssetPath;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onHomePressed;
  final VoidCallback? onSecondaryPressed;

  final String secondaryButtonText;
  final IconData secondaryButtonIcon;

  const _WrongFeedbackLayout({
    required this.title,
    required this.cardTitle,
    required this.mascotAssetPath,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.onHomePressed,
    required this.onSecondaryPressed,
    required this.secondaryButtonText,
    required this.secondaryButtonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mascotSize =
        (constraints.maxHeight * 0.31).clamp(205.0, 275.0).toDouble();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 70, 18, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WrongMockupHeader(
                  title: title,
                ),
                const SizedBox(height: 8),
                Center(
                  child: _WrongMockupMascot(
                    size: mascotSize,
                    mascotAssetPath: mascotAssetPath,
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: _WrongMockupCard(
                    title: cardTitle,
                    primaryButtonText: primaryButtonText,
                    onPrimaryPressed: onPrimaryPressed,
                    onHomePressed: onHomePressed,
                  ),
                ),
                if (onSecondaryPressed != null)
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: Center(
                      child: _SmallActionButton(
                        icon: secondaryButtonIcon,
                        label: secondaryButtonText,
                        accentColor: AppColors.error,
                        onPressed: onSecondaryPressed!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WrongMockupHeader extends StatelessWidget {
  final String title;


  const _WrongMockupHeader({
    required this.title,

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DGAgnadeen',
                color: AppColors.error,
                fontSize: 40,
                fontWeight: FontWeight.w900,
                height: 1.02,
                shadows: [
                  Shadow(
                    color: Color(0x25EC342F),
                    blurRadius: 9,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WrongMockupMascot extends StatelessWidget {
  final double size;
  final String mascotAssetPath;

  const _WrongMockupMascot({
    required this.size,
    required this.mascotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 54,
      height: size + 30,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.white.withValues(alpha: 0.92),
                  AppColors.pink.withValues(alpha: 0.16),
                  AppColors.red.withValues(alpha: 0.06),
                ],
                stops: const [0.08, 0.68, 1],
              ),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.94),
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
          ),
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.pink.withValues(alpha: 0.10),
                width: 1.4,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.035),
            child: Image.asset(
              mascotAssetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.error,
                  size: 110,
                );
              },
            ),
          ),
          Positioned(
            top: 28,
            left: 3,
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withValues(alpha: 0.12),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.pink,
                  size: 25,
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            right: 0,
            child: Icon(
              Icons.cloud_rounded,
              color: AppColors.white.withValues(alpha: 0.92),
              size: 43,
              shadows: const [
                Shadow(
                  color: Color(0x16000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 49,
            right: 8,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.yellow,
              size: 25,
            ),
          ),
          Positioned(
            bottom: 57,
            left: 10,
            child: Icon(
              Icons.circle,
              color: AppColors.pink.withValues(alpha: 0.55),
              size: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _WrongMockupCard extends StatelessWidget {
  final String title;
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onHomePressed;

  const _WrongMockupCard({
    required this.title,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.onHomePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 39),
          padding: const EdgeInsets.fromLTRB(20, 59, 20, 21),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.pink.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.pink.withValues(alpha: 0.12),
                blurRadius: 27,
                offset: const Offset(0, 13),
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DGAgnadeen',
                  color: AppColors.error,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.3,
                      color: AppColors.pink.withValues(alpha: 0.18),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.pink,
                      size: 15,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.3,
                      color: AppColors.pink.withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (onPrimaryPressed != null) ...[
                const SizedBox(height: 17),
                _FeedbackPrimaryButton(
                  accentColor: AppColors.error,
                  label: primaryButtonText,
                  isCorrect: false,
                  onPressed: onPrimaryPressed!,
                ),
              ],
              if (onHomePressed != null) ...[
                const SizedBox(height: 11),
                _WrongHomeButton(
                  onPressed: onHomePressed!,
                ),
              ],
            ],
          ),
        ),
        const _WrongMockupSeal(),
      ],
    );
  }
}


class _WrongHomeButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _WrongHomeButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.home_rounded,
          size: 24,
        ),
        label: const Text(
          'العودة للرئيسية',
          style: TextStyle(
            fontFamily: 'DGAgnadeen',
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pink,
          side: const BorderSide(
            color: AppColors.pink,
            width: 1.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

class _WrongMockupSeal extends StatelessWidget {
  const _WrongMockupSeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.pink.withValues(alpha: 0.16),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pink,
              AppColors.error,
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.88),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.white,
          size: 41,
        ),
      ),
    );
  }
}

class _FeedbackPrimaryButton extends StatefulWidget {
  final Color accentColor;
  final String label;
  final bool isCorrect;
  final VoidCallback onPressed;

  const _FeedbackPrimaryButton({
    required this.accentColor,
    required this.label,
    required this.isCorrect,
    required this.onPressed,
  });

  @override
  State<_FeedbackPrimaryButton> createState() =>
      _FeedbackPrimaryButtonState();
}

class _FeedbackPrimaryButtonState extends State<_FeedbackPrimaryButton> {
  bool _isProcessing = false;

  Future<void> _handlePressed() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    if (widget.isCorrect) {
      try {
        await context.read<CoinsCubit>().refreshCoins();
      } catch (_) {
        // Coin refresh must never block continuing the activity.
      }
    }

    if (!mounted) return;

    widget.onPressed();

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accentColor,
          disabledBackgroundColor:
          widget.accentColor.withValues(alpha: 0.72),
          foregroundColor: AppColors.white,
          disabledForegroundColor: AppColors.white,
          elevation: 4,
          shadowColor: widget.accentColor.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.white,
          ),
        )
            : Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'DGAgnadeen',
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _FeedbackActions extends StatelessWidget {
  final VoidCallback? onHomePressed;
  final VoidCallback? onSecondaryPressed;
  final String secondaryButtonText;
  final IconData secondaryButtonIcon;
  final Color accentColor;

  const _FeedbackActions({
    required this.onHomePressed,
    required this.onSecondaryPressed,
    required this.secondaryButtonText,
    required this.secondaryButtonIcon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onHomePressed != null)
          _SmallActionButton(
            icon: Icons.home_rounded,
            label: 'الرئيسية',
            accentColor: accentColor,
            onPressed: onHomePressed!,
          ),
        if (onHomePressed != null && onSecondaryPressed != null)
          const SizedBox(width: 38),
        if (onSecondaryPressed != null)
          _SmallActionButton(
            icon: secondaryButtonIcon,
            label: secondaryButtonText,
            accentColor: accentColor,
            onPressed: onSecondaryPressed!,
          ),
      ],
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
