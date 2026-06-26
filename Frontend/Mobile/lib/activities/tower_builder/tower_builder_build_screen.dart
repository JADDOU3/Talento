import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../cubits/activities/tower_builder/tower_builder_state.dart';
import '../../shared/layout/app_background.dart';
import 'tower_builder_checklist_screen.dart';
import 'widgets/target_image_widget.dart';

class TowerBuilderBuildScreen extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const TowerBuilderBuildScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<TowerBuilderBuildScreen> createState() =>
      _TowerBuilderBuildScreenState();
}

class _TowerBuilderBuildScreenState extends State<TowerBuilderBuildScreen> {
  @override
  void initState() {
    super.initState();

    context.read<TowerBuilderCubit>().loadGame(
      activityId: widget.activityId,
      activitySessionId: widget.activitySessionId,
      childId: widget.childId,
      sessionId: widget.sessionId,
    );
  }

  void _showHintComingSoon() {
    context.read<TowerBuilderCubit>().onHintPressed();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hints coming soon!'),
      ),
    );
  }

  void _goToChecklist(TowerBuilderLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TowerBuilderCubit>(),
          child: TowerBuilderChecklistScreen(
            checklist: state.level.checklist,
            currentAttemptId: state.currentAttemptId,
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
        child: BlocBuilder<TowerBuilderCubit, TowerBuilderState>(
          builder: (context, state) {
            if (state is TowerBuilderLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is TowerBuilderError) {
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

            if (state is TowerBuilderLevelComplete) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Level complete!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Great job! You completed this Tower Builder activity.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _finishActivity,
                        child: const Text('Finish'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is TowerBuilderLoaded) {
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
                              child: const Text('Give me a hint'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _goToChecklist(state),
                              child: const Text('Done Building'),
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