import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/color_lab/color_lab_cubit.dart';
import '../../cubits/activities/color_lab/color_lab_state.dart';
import '../../services/activities/color_lab_service.dart';
import '../../shared/audio/voice_over_controller.dart';
import '../../shared/layout/app_background.dart';
import 'color_lab_result_screen.dart';
import 'widgets/color_palette_widget.dart';
import 'widgets/free_coloring_widget.dart';
import 'widgets/mixing_bowl_widget.dart';
import 'widgets/target_image_widget.dart';
import 'widgets/undo_reset_controls.dart';
import '../../shared/layout/top_bar.dart';

class ColorLabGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int initialLevelNumber;

  const ColorLabGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.initialLevelNumber = 1,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ColorLabCubit(
        service: ColorLabService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      )..loadGame(
        startLevelId: startLevelId,
        initialLevelNumber: initialLevelNumber,
      ),
      child: _ColorLabGameView(
        startLevelId: startLevelId,
        initialLevelNumber: initialLevelNumber,
      ),
    );
  }
}

class _ColorLabGameView extends StatefulWidget {
  final int? startLevelId;
  final int initialLevelNumber;

  const _ColorLabGameView({
    required this.startLevelId,
    required this.initialLevelNumber,
  });

  @override
  State<_ColorLabGameView> createState() => _ColorLabGameViewState();
}

class _ColorLabGameViewState extends State<_ColorLabGameView> {
  final VoiceOverController _voiceOverController =
  VoiceOverController();

  Timer? _timer;
  bool _timerStarted = false;
  int? _lastPlayedLevelId;

  // Level 4 (free coloring) — read the result on submit via this key.
  final GlobalKey<FreeColoringWidgetState> _coloringKey =
  GlobalKey<FreeColoringWidgetState>();
  bool _hasColoring = false;

  Future<void> _playLevelVoiceOver(int levelId) async {
    if (levelId <= 0 || _lastPlayedLevelId == levelId) {
      return;
    }

    _lastPlayedLevelId = levelId;

    await _voiceOverController.playLevel(
      activityId: context.read<ColorLabCubit>().activityId,
      levelId: levelId,
    );
  }

  void _startTimer(BuildContext context) {
    if (_timerStarted) return;
    _timerStarted = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        context.read<ColorLabCubit>().onTimerTick();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _voiceOverController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    await _voiceOverController.stop();

    // Step D — log ENDED if not completed
    await context.read<ColorLabCubit>().logExitIfNotCompleted();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ColorLabCubit, ColorLabState>(
      listener: (context, state) async {
        if (state is ColorLabLoaded) {
          _startTimer(context);
          await _playLevelVoiceOver(state.level.id);
        }

        if (state is ColorLabChallengeResult) {
          // Stop the level explanation before the global SUCCESS / FAIL audio.
          await _voiceOverController.stop();

          // Show feedback screen, then advance.
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ColorLabResultScreen(
                isCorrect: state.isCorrect,
              ),
            ),
          );
          if (context.mounted) {
            context.read<ColorLabCubit>().nextChallenge();
          }
        }

        if (state is ColorLabLevelComplete) {
          _timer?.cancel();
          await _voiceOverController.stop();

          // The last challenge already showed the unified correct-answer screen.
          // After pressing "التالي", return directly to the roadmap.
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: WillPopScope(
            onWillPop: () => _onWillPop(context),
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: AppBackground(
                child: SafeArea(
                  child: _buildBody(context, state),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ColorLabState state) {
    if (state is ColorLabLoading || state is ColorLabInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ColorLabError) {
      return _buildError(context, state.message);
    }

    // For result state, keep showing the game behind (use snapshot)
    final loaded = state is ColorLabLoaded
        ? state
        : (state is ColorLabChallengeResult ? state.snapshot : null);

    if (loaded == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final palette = loaded.palette;
    final challenge = loaded.currentChallenge;

    return Column(
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_rounded,
          onLeadingPressed: () async {
            final canPop = await _onWillPop(context);

            if (canPop && context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(height: 8),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              children: [
                // Challenge progress
                Text(
                  'التحدي ${loaded.currentChallengeIndex + 1} من ${loaded.level.challenges.length}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),

                // ===== Level 4: Free coloring =====
                if (loaded.level.isFreeColoring) ...[
                  FreeColoringWidget(
                    key: _coloringKey,
                    challenge: challenge,
                    onColoringChanged: (has) {
                      if (mounted) setState(() => _hasColoring = has);
                    },
                  ),
                  const SizedBox(height: 18),
                  _SubmitButton(
                    enabled: _hasColoring,
                    onTap: () => _submitColoring(context),
                  ),
                ]
                // ===== Part 1: Palette-mix (unchanged) =====
                else ...[
                  // Target image
                  TargetImageWidget(challenge: challenge),
                  const SizedBox(height: 16),

                  // Mixing bowl
                  MixingBowlWidget(selectedColors: loaded.selectedColors),
                  const SizedBox(height: 14),

                  // Undo / Reset
                  UndoResetControls(
                    canUndo: loaded.selectedColors.isNotEmpty,
                    canReset: loaded.selectedColors.isNotEmpty,
                    undosLeft: loaded.undosLeft,
                    onUndo: () => context.read<ColorLabCubit>().undo(),
                    onReset: () => context.read<ColorLabCubit>().reset(),
                  ),
                  const SizedBox(height: 16),

                  // Palette — always shown (circles render even with no image)
                  ColorPaletteWidget(
                    paletteImage: palette,
                    onColorPicked: (color) =>
                        context.read<ColorLabCubit>().pickColor(color),
                  ),
                  const SizedBox(height: 18),

                  // Submit
                  _SubmitButton(
                    enabled: loaded.selectedColors.isNotEmpty,
                    onTap: () => context.read<ColorLabCubit>().submitMix(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _submitColoring(BuildContext context) {
    final eval = _coloringKey.currentState?.evaluateColoring();
    if (eval == null || !eval.hasColoring) return;
    context.read<ColorLabCubit>().submitColoring(
      hasColoring: eval.hasColoring,
      insideRatio: eval.insideRatio,
      dominantRgb: eval.dominantRgb,
      maskReliable: eval.maskReliable,
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () async {
                _timer?.cancel();
                _timerStarted = false;
                _lastPlayedLevelId = null;
                await _voiceOverController.stop();

                if (!context.mounted) return;

                context.read<ColorLabCubit>().loadGame(
                  startLevelId: widget.startLevelId,
                  initialLevelNumber: widget.initialLevelNumber,
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Text(
            'اخلط الألوان',
            style: AppTextStyles.button.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
