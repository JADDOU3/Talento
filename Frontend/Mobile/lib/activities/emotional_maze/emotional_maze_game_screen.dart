import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../maze_engine/tilt/tilt_controller.dart';
import '../../maze_engine/widgets/tilt_calibration_button.dart';
import '../../cubits/emotional_maze/emotional_maze_cubit.dart';
import '../../cubits/emotional_maze/emotional_maze_state.dart';
import '../../services/activities/emotional_maze_service.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/emotional_maze_game.dart';

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
      )..loadGame(startLevelId: startLevelId, startLevelNumber: startLevelNumber),
      child: _EmotionalMazeView(),
    );
  }
}

class _EmotionalMazeView extends StatefulWidget {
  @override
  State<_EmotionalMazeView> createState() => _EmotionalMazeViewState();
}

class _EmotionalMazeViewState extends State<_EmotionalMazeView> {
  final TiltController _tiltController = TiltController();
  EmotionalMazeGame? _game;
  Timer? _timer;
  bool _completedNavigated = false;
  EmotionalMazeLoaded? _lastLoaded;

  @override
  void dispose() {
    _timer?.cancel();
    _tiltController.stop();
    super.dispose();
  }

  void _startTimer(BuildContext context) {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<EmotionalMazeCubit>().onTimerTick();
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<EmotionalMazeCubit>().logExitIfNotCompleted();
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
              child: BlocConsumer<EmotionalMazeCubit, EmotionalMazeState>(
                listener: (context, state) {
                  if (state is EmotionalMazeLoaded) {
                    _startTimer(context);
                  }

                  if (state is EmotionalMazeComplete && !_completedNavigated) {
                    _completedNavigated = true;
                    _timer?.cancel();
                    _showCompleteDialog(context);
                  }
                },
                builder: (context, state) {
                  if (state is EmotionalMazeLoading ||
                      state is EmotionalMazeInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is EmotionalMazeError) {
                    return _buildError(context, state.message);
                  }

                  final loaded = state is EmotionalMazeLoaded
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

  Widget _buildPlayfield(BuildContext context, EmotionalMazeLoaded loaded) {
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
                _game ??= EmotionalMazeGame(
                  config: loaded.config,
                  tiltController: _tiltController,
                  onFinished: () =>
                      context.read<EmotionalMazeCubit>().onFinished(),
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
    );
  }

  Widget _buildTopBar(BuildContext context, EmotionalMazeLoaded loaded) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                _fmt(loaded.elapsed),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBanner(EmotionalMazeLoaded loaded) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology_alt_rounded, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              loaded.level.question,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.emoji_events_rounded, size: 60, color: AppColors.yellow),
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
    return Center(child: Text(message));
  }
}