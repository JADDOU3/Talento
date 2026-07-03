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
import 'widgets/cognitive_maze_game_widget.dart';

/// The Cognitive Maze play screen: question banner + maze image + transparent
/// Flame ball overlay, a count-up timer, and a calibrate button.
///
/// Differs from Bodily Maze in that:
/// - there's a question banner above the maze
/// - there's no tap-to-jump gesture (CognitiveMazeGame has none)
/// - wrong answers don't end the round — the ball resets and a toast shows,
///   handled via the transient CognitiveMazeWrongAnswer state
class CognitiveMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;

  const CognitiveMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
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
      )..loadGame(startLevelId: startLevelId),
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

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
                    );
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'إجابة خاطئة، حاول مرة أخرى 💪',
                            textAlign: TextAlign.right,
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                  }
                  if (state is CognitiveMazeComplete && !_completedNavigated) {
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

                  // Loaded / WrongAnswer / Complete all render the playfield
                  // from the last known Loaded snapshot.
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
    final correctIndex = loaded.level.correctChoiceIndex;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        children: [
          _buildTopBar(context, loaded),
          const SizedBox(height: 10),
          _buildQuestionBanner(loaded),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Build (or reuse) the game once we have a size + config.
                _game ??= CognitiveMazeGame(
                  config: loaded.config,
                  correctEndpointIndex: correctIndex,
                  tiltController: _tiltController,
                  onCorrectAnswer: () =>
                      context.read<CognitiveMazeCubit>().onCorrectAnswer(),
                  onWrongAnswer: (endpointIndex) => context
                      .read<CognitiveMazeCubit>()
                      .onWrongAnswer(endpointIndex),
                );

                return ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Maze image (presigned url — never s3Key).
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
                      // Transparent Flame overlay (only the ball is drawn).
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
    );
  }

  Widget _buildTopBar(BuildContext context, CognitiveMazeLoaded loaded) {
    return Row(
      children: [
        IconButton(
          onPressed: () async {
            if (await _onWillPop(context) && context.mounted) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textPrimary,
        ),
        const Spacer(),
        Image.asset('assets/icons/logo1.png', height: 40),
        const Spacer(),
        // Count-up timer.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                _fmt(loaded.elapsed),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Question banner shown above the maze — the child reads this, then
  /// navigates the ball toward the endpoint matching the correct choice.
  Widget _buildQuestionBanner(CognitiveMazeLoaded loaded) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded,
              size: 22, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loaded.level.question,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
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
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 64, color: AppColors.yellow),
              const SizedBox(height: 12),
              const Text(
                'أحسنت! وصلت للنهاية 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx); // close dialog
                  Navigator.pop(context); // leave game
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('تم'),
              ),
            ),
          ],
        ),
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