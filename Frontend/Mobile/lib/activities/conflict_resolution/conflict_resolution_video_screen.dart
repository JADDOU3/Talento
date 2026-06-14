import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/conflict_resolution/conflict_resolution_cubit.dart';
import '../../cubits/activities/conflict_resolution/conflict_resolution_state.dart';
import '../../screens/qr_scanner/qr_scanner_screen.dart';
import '../../services/activities/conflict_resolution_service.dart';
import '../../shared/layout/app_background.dart';
import 'conflict_resolution_result_screen.dart';
import 'widgets/timer_bar_widget.dart';
import 'widgets/video_player_widget.dart';

class ConflictResolutionVideoScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int initialLevelNumber;

  const ConflictResolutionVideoScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.initialLevelNumber = 1,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConflictResolutionCubit(
        conflictResolutionService: ConflictResolutionService(),
      )..loadGame(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
        initialLevelNumber: initialLevelNumber,
      ),
      child: _ConflictResolutionVideoView(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
        initialLevelNumber: initialLevelNumber,
      ),
    );
  }
}

class _ConflictResolutionVideoView extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int initialLevelNumber;

  const _ConflictResolutionVideoView({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    required this.initialLevelNumber,
  });

  @override
  State<_ConflictResolutionVideoView> createState() =>
      _ConflictResolutionVideoViewState();
}

class _ConflictResolutionVideoViewState
    extends State<_ConflictResolutionVideoView> {
  int _replayToken = 0;

  Future<void> _openScanner(BuildContext context) async {
    final cubit = context.read<ConflictResolutionCubit>();

    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(
          returnFirstScan: true,
        ),
      ),
    );

    if (!context.mounted) return;

    if (scannedValue != null && scannedValue.trim().isNotEmpty) {
      await cubit.onQrScanned(scannedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<ConflictResolutionCubit, ConflictResolutionState>(
        builder: (context, state) {
          return Scaffold(
            body: AppBackground(
              child: SafeArea(
                child: _buildBody(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ConflictResolutionState state) {
    if (state is ConflictResolutionLoading ||
        state is ConflictResolutionInitial) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is ConflictResolutionError) {
      return _ErrorView(message: state.message);
    }

    if (state is ConflictResolutionChallengeResult) {
      return ConflictResolutionResultScreen(
        isCorrect: state.isCorrect,
        onTryAgain: state.isCorrect
            ? null
            : () {
          context
              .read<ConflictResolutionCubit>()
              .returnToChallengeAfterWrong(state.previousState);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              _openScanner(context);
            }
          });
        },
      );
    }

    if (state is ConflictResolutionLevelComplete) {
      return _LevelCompleteView(message: state.message);
    }

    if (state is ConflictResolutionActivityComplete) {
      return ConflictResolutionResultScreen(
        isCorrect: true,
        isFinalComplete: true,
        elapsed: state.elapsed,
        onDone: () {
          Navigator.popUntil(
            context,
                (route) => route.isFirst,
          );
        },
      );
    }

    if (state is ConflictResolutionLoaded) {
      return _LoadedConflictView(
        state: state,
        replayToken: _replayToken,
        onReplay: () {
          setState(() {
            _replayToken++;
          });
        },
        onOpenScanner: () => _openScanner(context),
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoadedConflictView extends StatelessWidget {
  final ConflictResolutionLoaded state;
  final int replayToken;
  final VoidCallback onReplay;
  final VoidCallback onOpenScanner;

  const _LoadedConflictView({
    required this.state,
    required this.replayToken,
    required this.onReplay,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;

    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: _SoftBackgroundDecorations(),
          ),
        ),
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
          children: [
            const _TopHeader(),
            const SizedBox(height: 14),
            _LevelHeader(state: state),
            const SizedBox(height: 14),

            if (state.timerSeconds != null && state.timerRemaining != null) ...[
              TimerBarWidget(
                totalSeconds: state.timerSeconds!,
                remainingSeconds: state.timerRemaining!,
              ),
              const SizedBox(height: 14),
            ],

            VideoPlayerWidget(
              key: ValueKey(
                '${state.currentLevelIndex}-${state.currentChallengeIndex}',
              ),
              videoUrl: challenge.videoUrl,
              placeholderText: challenge.prompt,
              replayToken: replayToken,
              onVideoStarted: () {
                context.read<ConflictResolutionCubit>().onVideoStarted();
              },
              onVideoEnd: () {
                context.read<ConflictResolutionCubit>().onVideoFinished();
              },
            ),

            const SizedBox(height: 20),

            _TonkyQuestionCard(
              question: challenge.question,
              fallback: challenge.prompt,
            ),

            const SizedBox(height: 20),

            _ActionButtonsCard(
              canContinue: state.canContinue,
              onReplay: onReplay,
              onOpenScanner: onOpenScanner,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}
class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _TopCircleButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),
          const Spacer(),
          Image.asset(
            'assets/icons/logo1.png',
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Text(
                'Talento',
                style: TextStyle(
                  fontFamily: 'BerlinSans',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _TopCircleButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final ConflictResolutionLoaded state;

  const _LevelHeader({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final totalLevels = state.totalLevels <= 0 ? 5 : state.totalLevels;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.white.withValues(alpha: 0.78),
            AppColors.yellow.withValues(alpha: 0.12),
            AppColors.pink.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.88),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.90),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primary,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _levelTitle(state.currentLevelNumber),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'DGAgnadeen',
                        fontSize: 24,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _levelSubtitle(state.currentLevelNumber),
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'ArialRounded',
                        fontSize: 13.5,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(totalLevels, (index) {
              final levelNumber = index + 1;
              final isDone = levelNumber < state.currentLevelNumber;
              final isCurrent = levelNumber == state.currentLevelNumber;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    left: index == totalLevels - 1 ? 0 : 7,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: isCurrent ? 28 : 22,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isDone
                          ? AppColors.yellow.withValues(alpha: 0.90)
                          : AppColors.white.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : AppColors.white.withValues(alpha: 0.90),
                        width: 1.3,
                      ),
                      boxShadow: isCurrent
                          ? [
                        BoxShadow(
                          color:
                          AppColors.primary.withValues(alpha: 0.26),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: Center(
                      child: Icon(
                        isDone
                            ? Icons.check_rounded
                            : isCurrent
                            ? Icons.star_rounded
                            : Icons.circle_rounded,
                        size: isCurrent ? 17 : 11,
                        color: isCurrent
                            ? AppColors.white
                            : isDone
                            ? AppColors.textPrimary
                            : AppColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _levelTitle(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'مشاعري';
      case 2:
        return 'تصرف لطيف';
      case 3:
        return 'يدًا بيد';
      case 4:
        return 'أنا آسف';
      case 5:
        return 'نلعب بالدور';
      default:
        return 'تحدي جديد';
    }
  }

  String _levelSubtitle(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'نلاحظ الشعور ونفهمه';
      case 2:
        return 'نختار تصرفًا لطيفًا';
      case 3:
        return 'نتعاون ونساعد بعض';
      case 4:
        return 'نقول آسف بطريقة حلوة';
      case 5:
        return 'نلعب بالدور ونشارك';
      default:
        return 'اختر البطاقة المناسبة';
    }
  }
}

class _MiniProgressBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MiniProgressBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 12.2,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TonkyQuestionCard extends StatelessWidget {
  final String question;
  final String fallback;

  const _TonkyQuestionCard({
    required this.question,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final text = question.trim().isNotEmpty ? question : fallback;

    return SizedBox(
      height: 145,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 92,
            left: 0,
            top: 10,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.white.withValues(alpha: 0.96),
                    AppColors.yellow.withValues(alpha: 0.16),
                    AppColors.pink.withValues(alpha: 0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.yellow.withValues(alpha: 0.38),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.yellow.withValues(alpha: 0.14),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(-4, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.psychology_alt_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'اختر البطاقة المناسبة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DGAgnadeen',
                            fontSize: 22,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    text.trim().isEmpty ? 'ما البطاقة الصحيحة؟' : text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 16.8,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 82,
            top: 61,
            child: CustomPaint(
              size: const Size(24, 18),
              painter: _BubbleTailPainter(),
            ),
          ),
          Positioned(
            right: -10,
            top: 8,
            child: Image.asset(
              'assets/images/template_mascot.png',
              width: 132,
              height: 132,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.primary,
                    size: 56,
                  ),
                );
              },
            ),
          ),
          const Positioned(
            left: 18,
            top: -2,
            child: _SmallSparkle(
              color: AppColors.yellow,
              size: 16,
            ),
          ),
          const Positioned(
            left: 48,
            bottom: 2,
            child: _SmallSparkle(
              color: AppColors.pink,
              size: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.30,
        0,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.74,
        size.width,
        0,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.96)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BubbleTailPainter oldDelegate) {
    return false;
  }
}

class _ActionButtonsCard extends StatelessWidget {
  final bool canContinue;
  final VoidCallback onReplay;
  final VoidCallback onOpenScanner;

  const _ActionButtonsCard({
    required this.canContinue,
    required this.onReplay,
    required this.onOpenScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.78),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _GlowButton(
              label: 'إعادة',
              icon: Icons.replay_rounded,
              backgroundColor: AppColors.yellow,
              foregroundColor: AppColors.textPrimary,
              glowColor: AppColors.yellow,
              onPressed: onReplay,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _GlowButton(
              label: 'امسح البطاقة',
              icon: Icons.qr_code_scanner_rounded,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              glowColor: AppColors.primary,
              onPressed: canContinue ? onOpenScanner : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color glowColor;
  final VoidCallback? onPressed;

  const _GlowButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.glowColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.48,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: enabled
              ? [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.34),
              blurRadius: 18,
              spreadRadius: 1.2,
              offset: const Offset(0, 7),
            ),
            BoxShadow(
              color: AppColors.white.withValues(alpha: 0.40),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ]
              : [],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: backgroundColor.withValues(alpha: 0.42),
            disabledForegroundColor: foregroundColor.withValues(alpha: 0.72),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 20.5,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallSparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _SmallSparkle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SmallSparklePainter(color),
    );
  }
}

class _SmallSparklePainter extends CustomPainter {
  final Color color;

  const _SmallSparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(center.dx + size.width * 0.16, center.dy - size.height * 0.16)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx + size.width * 0.16, center.dy + size.height * 0.16)
      ..lineTo(center.dx, size.height)
      ..lineTo(center.dx - size.width * 0.16, center.dy + size.height * 0.16)
      ..lineTo(0, center.dy)
      ..lineTo(center.dx - size.width * 0.16, center.dy - size.height * 0.16)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SmallSparklePainter oldDelegate) {
    return false;
  }
}

class _SoftBackgroundDecorations extends StatelessWidget {
  const _SoftBackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SoftBackgroundDecorationsPainter(),
    );
  }
}

class _SoftBackgroundDecorationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final yellowPaint = Paint()
      ..color = AppColors.yellow.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    final pinkPaint = Paint()
      ..color = AppColors.pink.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final tealPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.09, size.height * 0.24),
      30,
      yellowPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.53),
      34,
      pinkPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.82),
      32,
      tealPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SoftBackgroundDecorationsPainter oldDelegate) {
    return false;
  }
}

class _LevelCompleteView extends StatelessWidget {
  final String message;

  const _LevelCompleteView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.yellow.withValues(alpha: 0.55),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎉',
                    style: TextStyle(fontSize: 46),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DGAgnadeen',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_rounded,
                color: AppColors.primary,
                size: 46,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'ArialRounded',
                  fontSize: 16.5,
                  height: 1.45,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'رجوع',
                    style: TextStyle(
                      fontFamily: 'DGAgnadeen',
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}