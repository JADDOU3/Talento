import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../cubits/cognitive_maze/cognitive_maze_cubit.dart';
import '../../cubits/cognitive_maze/cognitive_maze_state.dart';
import '../../services/activities/cognitive_maze_service.dart';
import '../../shared/layout/app_background.dart';
import '../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';
import 'widgets/cognitive_maze_game_widget.dart';
import '../../shared/layout/top_bar.dart';

class CognitiveMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int? startLevelNumber;

  const CognitiveMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CognitiveMazeCubit>(
      create: (_) => CognitiveMazeCubit(
        service: CognitiveMazeService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      )..loadGame(startLevelId: startLevelId, startLevelNumber: startLevelNumber),
      child: _CognitiveMazeView(),
    );
  }
}

class _CognitiveMazeView extends StatefulWidget {
  @override
  State<_CognitiveMazeView> createState() => _CognitiveMazeViewState();
}

class _CognitiveMazeViewState extends State<_CognitiveMazeView> {
  final TiltController _tiltController = TiltController();
  CognitiveMazeGame? _game;
  Timer? _timer;
  bool _completedNavigated = false;
  CognitiveMazeLoaded? _lastLoaded;

  @override
  void dispose() {
    _timer?.cancel();
    _tiltController.stop();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<CognitiveMazeCubit>().onTimerTick();
    });
  }



  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<CognitiveMazeCubit>().logExitIfNotCompleted();
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
          body: AppBackground(
            child: SafeArea(
              child: BlocConsumer<CognitiveMazeCubit, CognitiveMazeState>(
                listener: (context, state) {
                  if (state is CognitiveMazeLoaded) {
                    _startTimer(context);
                  }

                  if (state is CognitiveMazeWrongAnswer) {
                    _lastLoaded = CognitiveMazeLoaded(
                      level: state.level,
                      config: state.config,
                      elapsed: state.elapsed,
                      collectedColors: state.collectedColors,
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'الجواب غير صحيح، حاول مرة أخرى',
                            textAlign: TextAlign.right,
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                  }

                  if (state is CognitiveMazeComplete &&
                      !_completedNavigated) {
                    _completedNavigated = true;
                    _timer?.cancel();
                    _showCompleteDialog(context);
                  }
                },
                builder: (context, state) {
                  if (state is CognitiveMazeLoading ||
                      state is CognitiveMazeInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CognitiveMazeError) {
                    return _buildError(context, state.message);
                  }

                  final loaded = state is CognitiveMazeLoaded
                      ? state
                      : _lastLoaded;

                  if (loaded == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  _lastLoaded = loaded;
                  return _buildPlayfield(context, loaded);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildPlayfield(BuildContext context, CognitiveMazeLoaded loaded) {
    return Column(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _buildQuestionBanner(loaded),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _game ??= CognitiveMazeGame(
                        config: loaded.config,
                        correctEndpointIndex:
                        loaded.config.isStarCollectLevel
                            ? null
                            : loaded.level.correctChoiceIndex,
                        tiltController: _tiltController,
                        onCorrectAnswer: () => context
                            .read<CognitiveMazeCubit>()
                            .onCorrectAnswer(),
                        onWrongAnswer: (endpointIndex) => context
                            .read<CognitiveMazeCubit>()
                            .onWrongAnswer(endpointIndex),
                        onStarCollected: (color, isTarget) => context
                            .read<CognitiveMazeCubit>()
                            .onStarCollected(color, isTarget),
                      );

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              loaded.level.imageUrl,
                              fit: BoxFit.fill,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.inputFill,
                                child: const Center(
                                  child: Text('تعذّر تحميل صورة المتاهة'),
                                ),
                              ),
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
      ],
    );
  }


  Widget _buildQuestionBanner(CognitiveMazeLoaded loaded) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded,
              color: AppColors.primary),
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

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events_rounded,
                size: 60, color: AppColors.yellow),
            SizedBox(height: 12),
            Text(
              'أحسنت! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Navigator.pop(context);
              },
              child: const Text('تم'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Text(message),
    );
  }
}