import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/pattern_hacker/pattern_hacker_cubit.dart';
import '../../cubits/activities/pattern_hacker/pattern_hacker_state.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'pattern_hacker_result_screen.dart';
import 'widgets/pattern_choices_widget.dart';
import 'widgets/pattern_sequence_widget.dart';

class PatternHackerGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int initialLevelNumber;
  final int? startLevelId;

  const PatternHackerGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.initialLevelNumber = 1,
    this.startLevelId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatternHackerCubit()
        ..loadGame(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
          initialLevelNumber: initialLevelNumber,
          startLevelId: startLevelId,
        ),
      child: _PatternHackerGameView(
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
      ),
    );
  }
}

class _PatternHackerGameView extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const _PatternHackerGameView({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<_PatternHackerGameView> createState() => _PatternHackerGameViewState();
}

class _PatternHackerGameViewState extends State<_PatternHackerGameView> {
  void _onState(BuildContext context, PatternHackerState state) {
    if (state is! PatternHackerGameComplete) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PatternHackerResultScreen(
          elapsed: state.elapsed,
          activityId: widget.activityId,
          activitySessionId: widget.activitySessionId,
          childId: widget.childId,
          sessionId: widget.sessionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<PatternHackerCubit, PatternHackerState>(
        listener: _onState,
        builder: (context, state) {
          final isUnifiedFeedback =
              state is PatternHackerChallengeResult ||
                  state is PatternHackerLevelComplete;

          return Scaffold(
            body: isUnifiedFeedback
                ? _buildBody(context, state)
                : AppBackground(
              child: _buildBody(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, PatternHackerState state) {
    if (state is PatternHackerLoading || state is PatternHackerInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is PatternHackerError) {
      return _ErrorView(
        message: state.message,
        onRetry: () => Navigator.pop(context),
      );
    }

    if (state is PatternHackerChallengeResult) {
      return ActivityFeedbackView(
        type: state.isCorrect
            ? ActivityFeedbackType.correct
            : ActivityFeedbackType.wrong,
        onPrimaryPressed: state.isCorrect
            ? () {
          context
              .read<PatternHackerCubit>()
              .continueAfterChallengeResult();
        }
            : () {
          context
              .read<PatternHackerCubit>()
              .retryCurrentChallenge();
        },
      );
    }

    if (state is PatternHackerLevelComplete) {
      return ActivityFeedbackView(
        type: ActivityFeedbackType.correct,
        onPrimaryPressed: () {
          context.read<PatternHackerCubit>().continueAfterLevelComplete();
        },
      );
    }

    if (state is PatternHackerLoaded) {
      return _LoadedGameView(
        state: state,
      );
    }

    return const SizedBox.shrink();
  }
}

class _LoadedGameView extends StatelessWidget {
  final PatternHackerLoaded state;

  const _LoadedGameView({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 26,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _LevelHeader(state: state),
                          const SizedBox(height: 16),
                          PatternSequenceWidget(
                            sequence: challenge.sequence,
                            selectedIcon: state.selectedIcon,
                          ),
                          const SizedBox(height: 16),
                          _TonkyLevelDescription(
                            levelNumber: state.currentLevelNumber,
                          ),
                          const SizedBox(height: 16),
                          PatternChoicesWidget(
                            choices: challenge.choices,
                            selectedIcon: state.selectedIcon,
                            onChoiceSelected: (icon) {
                              context
                                  .read<PatternHackerCubit>()
                                  .selectChoice(icon);
                            },
                          ),
                          const SizedBox(height: 18),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state.canSubmit
                                  ? () => context
                                  .read<PatternHackerCubit>()
                                  .submitAnswer()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                disabledBackgroundColor: AppColors.border,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: state.canSubmit ? 4 : 0,
                              ),
                              child: const Text(
                                'تأكيد الإجابة',
                                style: TextStyle(
                                  fontFamily: 'DGAgnadeen',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final PatternHackerLoaded state;

  const _LevelHeader({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final levelName = state.level.name.trim().isNotEmpty
        ? state.level.name
        : 'المستوى ${state.currentLevelNumber}';

    return Column(
      children: [
        Text(
          levelName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'DGAgnadeen',
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'التحدي ${state.currentChallengeNumber} من ${state.totalChallenges}',
          style: const TextStyle(
            fontFamily: 'ArialRounded',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


class _TonkyLevelDescription extends StatelessWidget {
  final int levelNumber;

  const _TonkyLevelDescription({
    required this.levelNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(8, 0),
          child: Image.asset(
            'assets/images/template_mascot.png',
            width: 126,
            height: 126,
            fit: BoxFit.contain,
          ),
        ),
        Expanded(
          child: Container(
            transform: Matrix4.translationValues(6, 0, 0),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: AppColors.pink.withOpacity(0.14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.pink.withOpacity(0.22),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pink.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _descriptionForLevel(levelNumber),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'ArialRounded',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _descriptionForLevel(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'راقب تكرار الأشكال، ثم اختر الشكل الذي يُكمل النمط.';
      case 2:
        return 'انتبه لترتيب الأشكال جيدًا، وابحث عن القاعدة المتكررة.';
      case 3:
        return 'تابع النمط من اليمين إلى اليسار، ثم اختر الشكل التالي.';
      case 4:
        return 'بعض الأنماط تتغيّر خطوة بعد خطوة، ركّز في كل شكل.';
      case 5:
        return 'اجمع كل ما تعلّمته واكتشف الشكل الناقص في النمط.';
      default:
        return 'راقب ترتيب الأشكال، ثم اختر الشكل المناسب لإكمال النمط.';
    }
  }
}


class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: onRetry,
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'ArialRounded',
                        fontSize: 15,
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('رجوع'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
