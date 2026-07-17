import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../cubits/activities/bodily_maze/bodily_maze_cubit.dart';
import '../../cubits/activities/bodily_maze/bodily_maze_state.dart';
import '../../services/activities/bodily_maze_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'widgets/bodily_maze_game_widget.dart';

/// The Bodily Maze play screen: maze image + transparent Flame ball overlay,
/// a tap-to-jump gesture and a calibrate button.
class BodilyMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int? startLevelNumber;

  const BodilyMazeGameScreen({
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
    return BlocProvider<BodilyMazeCubit>(
      create: (_) => BodilyMazeCubit(
        service: BodilyMazeService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      )..loadGame(
        startLevelId: startLevelId,
        startLevelNumber: startLevelNumber,
      ),
      child: _BodilyMazeView(),
    );
  }
}

class _BodilyMazeView extends StatefulWidget {
  @override
  State<_BodilyMazeView> createState() => _BodilyMazeViewState();
}

class _BodilyMazeViewState extends State<_BodilyMazeView> {
  final TiltController _tiltController = TiltController();
  BodilyMazeGame? _game;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _tiltController.stop();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<BodilyMazeCubit>().onTimerTick();
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<BodilyMazeCubit>().logExitIfNotCompleted();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<BodilyMazeCubit, BodilyMazeState>(
            listener: (context, state) {
              if (state is BodilyMazeLoaded) {
                _startTimer(context);
              }

              if (state is BodilyMazeComplete) {
                _timer?.cancel();
              }
            },
            builder: (context, state) {
              if (state is BodilyMazeComplete) {
                return ActivityFeedbackView(
                  type: ActivityFeedbackType.correct,
                  onPrimaryPressed: () {
                    Navigator.of(context).pop();
                  },
                );
              }

              if (state is BodilyMazeLoading ||
                  state is BodilyMazeInitial) {
                return const AppBackground(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is BodilyMazeError) {
                return AppBackground(
                  child: _buildError(context, state.message),
                );
              }

              // Loaded / Failed both render the playfield.
              final loaded = state is BodilyMazeLoaded
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

  BodilyMazeLoaded? _lastLoaded;

  Widget _buildPlayfield(BuildContext context, BodilyMazeLoaded loaded) {
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
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          _game ??= BodilyMazeGame(
                            config: loaded.config,
                            tiltController: _tiltController,
                            onFellInHole: () => context
                                .read<BodilyMazeCubit>()
                                .onBallFellInHole(),
                            onReachedEnd: () => context
                                .read<BodilyMazeCubit>()
                                .onBallReachedEnd(),
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
                                    loaded.level.imageUrl,
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