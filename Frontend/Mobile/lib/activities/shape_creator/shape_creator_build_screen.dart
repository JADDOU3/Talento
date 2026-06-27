import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../shared/layout/app_background.dart';
//import 'shape_creator_checklist_screen.dart';
import 'widgets/target_image_widget.dart';
import 'shape_creator_pin_screen.dart';

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
          targetImageUrl: state.level.imageUrl,
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

            if (state is ShapeCreatorLevelComplete) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'أحسنت! اكتمل المستوى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'أحسنت! لقد أنهيت نشاط صانع الأشكال.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _finishActivity,
                        child: const Text('إنهاء'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ShapeCreatorLoaded) {
              final level = state.level;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Center(
                          child: TargetImageWidget(
                            imageUrl: level.imageUrl,
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