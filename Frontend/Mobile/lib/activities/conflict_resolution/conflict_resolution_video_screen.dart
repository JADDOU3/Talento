import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/conflict_resolution/conflict_resolution_cubit.dart';
import '../../cubits/activities/conflict_resolution/conflict_resolution_state.dart';
import '../../screens/qr_scanner/qr_scanner_screen.dart';
import '../../services/activities/conflict_resolution_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/button.dart';
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
    return BlocBuilder<ConflictResolutionCubit, ConflictResolutionState>(
      builder: (context, state) {
        if (state is ConflictResolutionLoading ||
            state is ConflictResolutionInitial) {
          return _buildScaffold(
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (state is ConflictResolutionError) {
          return _buildScaffold(
            child: _ErrorView(
              message: state.message,
              onBack: () => Navigator.pop(context),
            ),
          );
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
          return _buildScaffold(
            child: Center(
              child: _LevelCompleteCard(
                message: state.message,
              ),
            ),
          );
        }

        if (state is ConflictResolutionActivityComplete) {
          return ConflictResolutionResultScreen(
            isCorrect: true,
            isFinalComplete: true,
            elapsed: state.elapsed,
            onDone: () => Navigator.pop(context),
          );
        }

        if (state is ConflictResolutionLoaded) {
          return _buildLoaded(context, state);
        }

        return _buildScaffold(
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildLoaded(
      BuildContext context,
      ConflictResolutionLoaded state,
      ) {
    final challenge = state.challenge;

    return _buildScaffold(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          child: Column(
            children: [
              _HeaderCard(state: state),
              const SizedBox(height: 16),
              if (state.timerSeconds != null &&
                  state.timerRemaining != null) ...[
                TimerBarWidget(
                  totalSeconds: state.timerSeconds!,
                  remainingSeconds: state.timerRemaining!,
                ),
                const SizedBox(height: 16),
              ],
              VideoPlayerWidget(
                key: ValueKey(
                  '${state.currentLevelIndex}-${state.currentChallengeIndex}',
                ),
                videoUrl: challenge.videoUrl,
                placeholderText: challenge.prompt,
                replayToken: _replayToken,
                onVideoStarted: () {
                  context.read<ConflictResolutionCubit>().onVideoStarted();
                },
                onVideoEnd: () {
                  context.read<ConflictResolutionCubit>().onVideoFinished();
                },
              ),
              const SizedBox(height: 20),
              _QuestionCard(
                question: challenge.question,
                fallback: challenge.prompt,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ActivityTemplateButton(
                      text: 'إعادة',
                      backgroundColor: AppColors.yellow,
                      textColor: AppColors.textPrimary,
                      height: 62,
                      fontSize: 22,
                      onPressed: () {
                        setState(() {
                          _replayToken++;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Opacity(
                      opacity: state.canContinue ? 1.0 : 0.45,
                      child: ActivityTemplateButton(
                        text: 'متابعة',
                        backgroundColor: AppColors.primary,
                        height: 62,
                        fontSize: 22,
                        onPressed: state.canContinue
                            ? () => _openScanner(context)
                            : () {},
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaffold({
    required Widget child,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: child,
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ConflictResolutionLoaded state;

  const _HeaderCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.handshake_rounded,
            color: AppColors.primary,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'المستوى ${state.currentLevelNumber}/${state.totalLevels} • التحدي ${state.currentChallengeNumber}/${state.totalChallenges}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String fallback;

  const _QuestionCard({
    required this.question,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final text = question.trim().isNotEmpty ? question : fallback;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
          width: 2,
        ),
      ),
      child: Text(
        text.trim().isEmpty ? 'اختاري البطاقة المناسبة.' : text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w900,
          height: 1.45,
        ),
      ),
    );
  }
}

class _LevelCompleteCard extends StatelessWidget {
  final String message;

  const _LevelCompleteCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 14),
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
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorView({
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ActivityTemplateButton(
                  text: 'رجوع',
                  backgroundColor: AppColors.primary,
                  height: 60,
                  fontSize: 22,
                  onPressed: onBack,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}