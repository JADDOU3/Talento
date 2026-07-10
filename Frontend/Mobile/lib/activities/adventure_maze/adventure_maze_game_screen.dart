import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/adventure_maze/adventure_maze_cubit.dart';
import '../../cubits/activities/adventure_maze/adventure_maze_state.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../services/activities/adventure_maze_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'widgets/adventure_maze_game_widget.dart';
import 'widgets/star_progress_bar.dart';
import 'widgets/star_question_popup.dart';

class AdventureMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;

  const AdventureMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdventureMazeCubit>(
      create: (_) => AdventureMazeCubit(
        service: AdventureMazeService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      )..loadGame(startLevelId: startLevelId),
      child: _AdventureMazeView(),
    );
  }
}

class _AdventureMazeView extends StatefulWidget {
  @override
  State<_AdventureMazeView> createState() => _AdventureMazeViewState();
}

class _AdventureMazeViewState extends State<_AdventureMazeView> {
  final TiltController _tiltController = TiltController();
  AdventureMazeGame? _game;
  Timer? _timer;
  bool _popupOpen = false;
  int? _lastCollectedCount;
  bool _endBlockRemoved = false;

  @override
  void dispose() {
    _timer?.cancel();
    _tiltController.stop();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<AdventureMazeCubit>().onTimerTick();
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<AdventureMazeCubit>().logExitIfNotCompleted();
    return true;
  }

  void _openPopupIfNeeded(BuildContext context, AdventureMazeLoaded loaded) {
    if (_popupOpen) return;
    final cid = loaded.activeChallengeId;
    if (cid == null) return;

    final challenge = loaded.challenges.firstWhere(
          (c) => c.challengeId == cid,
    );

    _popupOpen = true;
    _game?.pauseForPopup();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StarQuestionPopup(
        challenge: challenge,
        onChoiceSelected: (choice) {
          final valid = context
              .read<AdventureMazeCubit>()
              .onChoiceSelected(cid, choice);
          if (valid) {
            Navigator.of(dialogCtx).pop();
          }
          return valid;
        },
      ),
    ).then((_) {
      _popupOpen = false;
      _game?.resumeFromPopup();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<AdventureMazeCubit, AdventureMazeState>(
            listener: (context, state) {
              if (state is AdventureMazeLoaded) {
                _startTimer(context);

                // A star was just collected — tell the game to fade it
                // out and possibly remove the end block.
                final newCount = state.collectedChallengeIds.length;
                if (_lastCollectedCount != null &&
                    newCount > _lastCollectedCount!) {
                  final previousCount = _lastCollectedCount ?? 0;

                  if (newCount > previousCount) {
                    for (final id in state.collectedChallengeIds) {
                      _game?.markStarCollected(id);
                    }
                  }
                }

                _lastCollectedCount = newCount;

                if (!_endBlockRemoved && state.allStarsCollected) {
                  _endBlockRemoved = true;
                  _game?.removeEndBlock();
                }

                _openPopupIfNeeded(context, state);
              }

              if (state is AdventureMazeComplete) {
                _timer?.cancel();
              }
            },
            builder: (context, state) {
              if (state is AdventureMazeComplete) {
                return ActivityFeedbackView(
                  type: ActivityFeedbackType.correct,
                  onPrimaryPressed: () {
                    Navigator.of(context).pop();
                  },
                );
              }

              if (state is AdventureMazeLoading ||
                  state is AdventureMazeInitial) {
                return const AppBackground(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is AdventureMazeError) {
                return AppBackground(
                  child: _buildError(context, state.message),
                );
              }

              final loaded = state is AdventureMazeLoaded
                  ? state
                  : _lastLoaded;

              if (loaded == null) {
                return const AppBackground(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              _lastLoaded = loaded;
              return _buildPlayfield(context, loaded);
            },
          ),
        ),
      ),
    );
  }

  AdventureMazeLoaded? _lastLoaded;

  Widget _buildPlayfield(
      BuildContext context,
      AdventureMazeLoaded loaded,
      ) {
    return AppBackground(
      child: Column(
        children: [
          TopBar(
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () async {
              if (await _onWillPop(context) && context.mounted) {
                Navigator.pop(context);
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
                    StarProgressBar(
                      orderedChallengeIds: loaded.challenges
                          .map((challenge) => challenge.challengeId)
                          .toList(),
                      collectedChallengeIds: loaded.collectedChallengeIds,
                      starColors: loaded.config.starColors,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          _game ??= AdventureMazeGame(
                            config: loaded.config,
                            tiltController: _tiltController,
                            starChallengeIds: loaded.challenges
                                .map((challenge) => challenge.challengeId)
                                .toList(),
                            onFellInHole: () => context
                                .read<AdventureMazeCubit>()
                                .onBallFellInHole(),
                            onReachedEnd: () => context
                                .read<AdventureMazeCubit>()
                                .onBallReachedEnd(),
                            onStarTouched: (challengeId) => context
                                .read<AdventureMazeCubit>()
                                .onStarTouched(challengeId),
                          );

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: GestureDetector(
                              onTapDown: (_) => _game?.startHold(),
                              onTapUp: (_) => _game?.stopHold(),
                              onTapCancel: () => _game?.stopHold(),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    loaded.level.mapImageUrl,
                                    fit: BoxFit.fill,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.inputFill,
                                      child: const Center(
                                        child: Text(
                                          'تعذّر تحميل صورة المتاهة',
                                        ),
                                      ),
                                    ),
                                  ),
                                  GameWidget(game: _game!),
                                ],
                              ),
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



  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 52, color: AppColors.hint),
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
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('رجوع'),
            ),
          ],
        ),
      ),
    );
  }
}
