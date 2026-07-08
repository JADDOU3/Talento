import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';

class ConflictResolutionResultScreen extends StatelessWidget {
  final bool isCorrect;
  final bool isFinalComplete;
  final Duration? elapsed;
  final VoidCallback? onTryAgain;
  final VoidCallback? onDone;

  const ConflictResolutionResultScreen({
    super.key,
    required this.isCorrect,
    this.isFinalComplete = false,
    this.elapsed,
    this.onTryAgain,
    this.onDone,
  });

  bool get _showCorrectFeedback => isCorrect || isFinalComplete;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: _showCorrectFeedback
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,
        onPrimaryPressed: () {
          if (isFinalComplete) {
            if (onDone != null) {
              onDone!();
            } else {
              Navigator.of(context).pop();
            }
            return;
          }

          if (!isCorrect) {
            if (onTryAgain != null) {
              onTryAgain!();
            } else {
              Navigator.of(context).pop();
            }
            return;
          }

          if (onDone != null) {
            onDone!();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }
}