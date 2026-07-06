import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../cubits/bodily_maze/bodily_maze_cubit.dart';
import '../../cubits/bodily_maze/bodily_maze_state.dart';
import '../../services/activities/bodily_maze_service.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/bodily_maze_game_widget.dart';
import '../../shared/layout/top_bar.dart';

/// The Bodily Maze play screen: maze image + transparent Flame ball overlay,
/// a count-up timer, a tap-to-jump gesture, and a calibrate button.
class BodilyMazeGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;

  const BodilyMazeGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
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
      )..loadGame(startLevelId: startLevelId),
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
  bool _completedNavigated = false;

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
          body: AppBackground(
            child: SafeArea(
              child: BlocConsumer<BodilyMazeCubit, BodilyMazeState>(
                listener: (context, state) {
                  if (state is BodilyMazeLoaded) {
                    _startTimer(context);
                  }
                  if (state is BodilyMazeComplete && !_completedNavigated) {
                    _completedNavigated = true;
                    _timer?.cancel();
                    _showCompleteDialog(context);
                  }
                },
                builder: (context, state) {
                  if (state is BodilyMazeLoading ||
                      state is BodilyMazeInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is BodilyMazeError) {
                    return _buildError(context, state.message);
                  }

                  // Loaded / Failed both render the playfield.
                  final loaded = state is BodilyMazeLoaded
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

  BodilyMazeLoaded? _lastLoaded;

  Widget _buildPlayfield(BuildContext context, BodilyMazeLoaded loaded) {
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

  Widget _buildTopBar(BuildContext context, BodilyMazeLoaded loaded) {
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
            ),
          ),
        ),
      ],
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
