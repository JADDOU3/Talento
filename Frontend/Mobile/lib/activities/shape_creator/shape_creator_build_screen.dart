import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../shared/layout/app_background.dart';
//import 'shape_creator_checklist_screen.dart';
import 'widgets/target_image_widget.dart';
import 'shape_creator_pin_screen.dart';
import '../../core/theme/app_colors.dart';

class ShapeCreatorBuildScreen extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const ShapeCreatorBuildScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<ShapeCreatorBuildScreen> createState() =>
      _ShapeCreatorBuildScreenState();
}

class _ShapeCreatorBuildScreenState extends State<ShapeCreatorBuildScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ShapeCreatorCubit>().loadGame(
      activityId: widget.activityId,
      activitySessionId: widget.activitySessionId,
      childId: widget.childId,
      sessionId: widget.sessionId,
    );
  }

  void _showHintComingSoon() {
    context.read<ShapeCreatorCubit>().onHintPressed();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('التلميحات قادمة قريباً'),
      ),
    );
  }

  void _goToPinScreen(ShapeCreatorLoaded state) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<ShapeCreatorCubit>(),
        child: ShapeCreatorPinScreen(
          checklist: state.level.checklist,
          currentAttemptId: state.currentAttemptId,
          targetImageUrl: 
           state.level.challengeImages[state.currentChallengeIndex],
        ),
      ),
    ),
  );
}

  void _finishActivity() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: BlocBuilder<ShapeCreatorCubit, ShapeCreatorState>(
          builder: (context, state) {
            if (state is ShapeCreatorLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ShapeCreatorError) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            if (state is ShapeCreatorLevelFinished) {
              print("BUILD SCREEN RECEIVED LEVEL FINISHED");
  return Scaffold(
    backgroundColor: Colors.green,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 120,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            'ممتاز! لقد أنهيت المستوى ${state.levelNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}


            if (state is ShapeCreatorLoaded) {
              final level = state.level;
              final currentImage = level.challengeImages[
               state.currentChallengeIndex
                     ];

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      _TopInfoBar(
                       elapsed: state.elapsed,
                     ),

const SizedBox(height: 20),
                      Expanded(
                        child: Center(
                          child: TargetImageWidget(
                             imageUrl: currentImage,
                             prompt: level.prompt,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        level.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Attempt ${state.attemptNumber}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _showHintComingSoon,
                              child: const Text('أعطني تلميحاً'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _goToPinScreen(state),
                              child: const Text('تم البناء'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
  
}
class _TopInfoBar extends StatelessWidget {
  final Duration elapsed;

  const _TopInfoBar({
    required this.elapsed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _TopCircleButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),

          const SizedBox(width: 8),

          _InfoPill(
            icon: Icons.timer_rounded,
            text: _formatDuration(elapsed),
          ),

          const Spacer(),

          Image.asset(
  'assets/icons/logo1.png',
  height: 50,
  fit: BoxFit.contain,
  errorBuilder: (_, __, ___) {
    return const Text(
      'Talento',
      style: TextStyle(
        fontFamily: 'BerlinSans',
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  },
),
        ],
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _TopCircleButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(
          icon,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes =
      duration.inMinutes.remainder(60).toString().padLeft(2, '0');

  final seconds =
      duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  return '$minutes:$seconds';
}