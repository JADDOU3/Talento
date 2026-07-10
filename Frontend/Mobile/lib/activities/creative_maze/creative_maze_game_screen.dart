import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/creative_maze/creative_maze_cubit.dart';
import '../../cubits/activities/creative_maze/creative_maze_state.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'widgets/creative_maze_game_widget.dart';

/// Creative Maze:
///
/// - There is no wrong-answer state.
/// - Reaching the end displays the shared success screen.
/// - This roadmap card contains one level only.
/// - Pressing the success button returns to the roadmap.
/// - There are no automatic transitions.
class CreativeMazeGameScreen extends StatefulWidget {
  const CreativeMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber,
  });

  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int? startLevelNumber;

  @override
  State<CreativeMazeGameScreen> createState() =>
      _CreativeMazeGameScreenState();
}

class _CreativeMazeGameScreenState
    extends State<CreativeMazeGameScreen> {
  late final TiltController _tiltController;
  late final CreativeMazeCubit _cubit;

  CreativeMazeGame? _game;

  @override
  void initState() {
    super.initState();

    _tiltController = TiltController();

    _cubit = CreativeMazeCubit()
      ..loadGame(
        activityId: widget.activityId,
        activitySessionId: widget.activitySessionId,
        childId: widget.childId,
        sessionId: widget.sessionId,
        startLevelId: widget.startLevelId,
        startLevelNumber: widget.startLevelNumber,
      );
  }

  @override
  void dispose() {
    _tiltController.stop();
    _cubit.close();
    super.dispose();
  }

  void _returnToRoadmap() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<CreativeMazeCubit, CreativeMazeState>(
          bloc: _cubit,
          listener: (context, state) {
            if (state is CreativeMazeComplete) {
              _tiltController.stop();
            }
          },
          builder: (context, state) {
            if (state is CreativeMazeLoading ||
                state is CreativeMazeInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is CreativeMazeError) {
              return _buildError(state.message);
            }

            if (state is CreativeMazeComplete) {
              return ActivityFeedbackView(
                type: ActivityFeedbackType.correct,
                onPrimaryPressed: _returnToRoadmap,
              );
            }

            if (state is CreativeMazeLoaded) {
              return _buildGame(state);
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGame(CreativeMazeLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE9FAF6),
            Color(0xFFFFF9EA),
            Color(0xFFFFEEF3),
          ],
        ),
      ),
      child: Column(
        children: [
          TopBar(
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              state.level.imageUrl,
                              fit: BoxFit.fill,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 48,
                                    color: Colors.black26,
                                  ),
                                );
                              },
                            ),
                            Builder(
                              builder: (context) {
                                _game ??= CreativeMazeGame(
                                  tiltController: _tiltController,
                                  config: state.config,
                                  onReachedEnd: _cubit.onBallReachedEnd,
                                );

                                return GameWidget(
                                  game: _game!,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TiltCalibrationButton(
                      tiltController: _tiltController,
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

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF123835),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
