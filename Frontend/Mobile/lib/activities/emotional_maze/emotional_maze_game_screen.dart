import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/emotional_maze/emotional_maze_cubit.dart';
import '../../cubits/activities/emotional_maze/emotional_maze_state.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../services/activities/emotional_maze_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'widgets/emotional_maze_game.dart';

/// Emotional Maze:
///
/// - There is no wrong-answer state.
/// - Reaching the end displays the shared success screen.
/// - This roadmap card contains one level only.
/// - Pressing the success button returns to the roadmap.
/// - There are no automatic transitions.
class EmotionalMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int? startLevelNumber;

  const EmotionalMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmotionalMazeCubit>(
      create: (_) => EmotionalMazeCubit(
        service: EmotionalMazeService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      )..loadGame(
        startLevelId: startLevelId,
        startLevelNumber: startLevelNumber,
      ),
      child: const _EmotionalMazeView(),
    );
  }
}

class _EmotionalMazeView extends StatefulWidget {
  const _EmotionalMazeView();

  @override
  State<_EmotionalMazeView> createState() => _EmotionalMazeViewState();
}

class _EmotionalMazeViewState extends State<_EmotionalMazeView> {
  final TiltController _tiltController = TiltController();

  EmotionalMazeGame? _game;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _tiltController.stop();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    _timer ??= Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          context.read<EmotionalMazeCubit>().onTimerTick();
        }
      },
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<EmotionalMazeCubit>().logExitIfNotCompleted();
    return true;
  }

  void _returnToRoadmap(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<EmotionalMazeCubit, EmotionalMazeState>(
            listener: (context, state) {
              if (state is EmotionalMazeLoaded) {
                _startTimer(context);
              }

              if (state is EmotionalMazeComplete) {
                _timer?.cancel();
                _tiltController.stop();
              }
            },
            builder: (context, state) {
              if (state is EmotionalMazeLoading ||
                  state is EmotionalMazeInitial) {
                return const AppBackground(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is EmotionalMazeError) {
                return _buildError(context, state.message);
              }

              if (state is EmotionalMazeComplete) {
                return ActivityFeedbackView(
                  type: ActivityFeedbackType.correct,
                  onPrimaryPressed: () => _returnToRoadmap(context),
                );
              }

              if (state is EmotionalMazeLoaded) {
                return _buildPlayfield(context, state);
              }

              return const AppBackground(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayfield(
      BuildContext context,
      EmotionalMazeLoaded loaded,
      ) {
    return AppBackground(
      child: Column(
        children: [
          TopBar(
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () async {
              if (await _onWillPop(context) && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _buildQuestionBanner(loaded),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          _game ??= EmotionalMazeGame(
                            config: loaded.config,
                            tiltController: _tiltController,
                            onFinished: () {
                              context
                                  .read<EmotionalMazeCubit>()
                                  .onFinished();
                            },
                          );

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  loaded.level.imageUrl,
                                  fit: BoxFit.fill,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: AppColors.inputFill,
                                      child: const Center(
                                        child: Text(
                                          'تعذّر تحميل صورة المتاهة',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                GameWidget(game: _game!),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TiltCalibrationButton(
                      tiltController: _tiltController,
                      onCalibrated: () => _game?.calibrate(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionBanner(EmotionalMazeLoaded loaded) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.psychology_alt_rounded,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loaded.level.question,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
      BuildContext context,
      String message,
      ) {
    return AppBackground(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 52,
                  color: AppColors.hint,
                ),
                const SizedBox(height: 14),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('رجوع'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
