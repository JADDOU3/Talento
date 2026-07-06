import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/creative_maze/creative_maze_cubit.dart';
import '../../cubits/activities/creative_maze/creative_maze_state.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import 'widgets/creative_maze_game_widget.dart';
import '../../shared/layout/top_bar.dart';

/// Hosts the running Creative Maze: the maze image is the play area with the
/// transparent Flame game (ball + physics walls from config) on top, plus a
/// calibrate button. No timer is shown to the child.
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
  State<CreativeMazeGameScreen> createState() => _CreativeMazeGameScreenState();
}

class _CreativeMazeGameScreenState extends State<CreativeMazeGameScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9FAF6), Color(0xFFFFF9EA), Color(0xFFFFEEF3)],
            ),
          ),
          child: BlocConsumer<CreativeMazeCubit, CreativeMazeState>(
              bloc: _cubit,
              listener: (context, state) {
                if (state is CreativeMazeComplete) {
                  _onComplete(state.completionTime);
                }
              },
              builder: (context, state) {
                if (state is CreativeMazeLoading ||
                    state is CreativeMazeInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CreativeMazeError) {
                  return _buildError(state.message);
                }
                if (state is CreativeMazeLoaded) {
                  return _buildGame(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
    );
  }

  Widget _buildGame(CreativeMazeLoaded state) {
    return Column(
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () => Navigator.pop(context),
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
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              _game ??= CreativeMazeGame(
                                tiltController: _tiltController,
                                config: state.config,
                                onReachedEnd: _cubit.onBallReachedEnd,
                              );

                              return GameWidget(game: _game!);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TiltCalibrationButton(tiltController: _tiltController),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.error),
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

  void _onComplete(Duration time) {
    final seconds = time.inSeconds;
    final mm = (seconds ~/ 60).toString().padLeft(2, '0');
    final ss = (seconds % 60).toString().padLeft(2, '0');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('أحسنت! 🎉', textAlign: TextAlign.center),
          content: Text(
            'وصلت للنهاية بوقت $mm:$ss',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                child: const Text('تمام'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
