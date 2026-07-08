import 'package:flutter/material.dart';

import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';

class EmpathyMirrorResultScreen extends StatelessWidget {
  final bool isCorrect;
  final VoidCallback onNext;

  const EmpathyMirrorResultScreen({
    super.key,
    required this.isCorrect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ActivityFeedbackView(
        type: isCorrect
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,
        onPrimaryPressed: onNext,
      ),
    );
  }
}