import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/emotion_chain/emotion_chain_cubit.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_state.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';

/// Unified result feedback for Emotion Chain.
///
/// Correct answers continue automatically through the cubit.
/// Wrong answers wait for the child to press "حاول مرة أخرى".
class EmotionChainResultView extends StatelessWidget {
  final EmotionChainStepResult state;

  const EmotionChainResultView({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.isCorrect;

    return Scaffold(
      body: ActivityFeedbackView(
        type: isCorrect
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,

        // الصح ينتقل تلقائيًا من الـ Cubit، لذلك ما بنغيّر منطق اللعبة.
        onPrimaryPressed: isCorrect
            ? null
            : () {
          context.read<EmotionChainCubit>().retryStep();
        },
      ),
    );
  }
}