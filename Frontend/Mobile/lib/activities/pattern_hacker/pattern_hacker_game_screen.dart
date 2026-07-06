import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/pattern_hacker/pattern_hacker_cubit.dart';
import '../../cubits/activities/pattern_hacker/pattern_hacker_state.dart';
import '../../services/tts_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
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
  final TtsService _tts = TtsService();
  int _lastHintLevel = 0;
  bool _lastRandomPress = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _onState(BuildContext context, PatternHackerState state) {
    if (state is PatternHackerGameComplete) {
      _tts.speak('أحسنت! لقد أنهيت كل المستويات');

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

      return;
    }

    if (state is PatternHackerChallengeResult) {
      _tts.speak(state.isCorrect ? 'إجابة صحيحة' : 'قريب، حاول مرة أخرى');
      _lastHintLevel = 0;
      _lastRandomPress = false;
      return;
    }

    if (state is PatternHackerLevelComplete) {
      _tts.speak(state.message);
      return;
    }

    if (state is PatternHackerLoaded) {
      if (state.randomPress && !_lastRandomPress) {
        _tts.speak(mascotHintText(state.hintLevel, true));
      } else if (state.hintLevel != _lastHintLevel && state.hintLevel >= 1) {
        _tts.speak(mascotHintText(state.hintLevel, false));
      }

      _lastHintLevel = state.hintLevel;
      _lastRandomPress = state.randomPress;
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<PatternHackerCubit, PatternHackerState>(
        listener: _onState,
        builder: (context, state) {
          return Scaffold(
            body: AppBackground(
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
      return _FeedbackView(
        isCorrect: state.isCorrect,
      );
    }

    if (state is PatternHackerLevelComplete) {
      return _LevelCompleteView(
        message: state.message,
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
                            hintLevel: state.hintLevel,
                          ),
                          const SizedBox(height: 16),
                          _MascotHint(
                            hintLevel: state.hintLevel,
                            randomPress: state.randomPress,
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

class _FeedbackView extends StatelessWidget {
  final bool isCorrect;

  const _FeedbackView({
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 22,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  isCorrect ? 'إجابة صحيحة 🎉' : 'قريب! جرّب مرة أخرى 💪',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isCorrect ? AppColors.primary : AppColors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelCompleteView extends StatelessWidget {
  final String message;

  const _LevelCompleteView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
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

/// The mascot (Tonky) with a reactive speech bubble. The text escalates with
/// the hint level and reacts to random pressing.
class _MascotHint extends StatelessWidget {
  final int hintLevel;
  final bool randomPress;

  const _MascotHint({
    required this.hintLevel,
    required this.randomPress,
  });

  @override
  Widget build(BuildContext context) {
    final isActiveHint = randomPress || hintLevel >= 1;
    final bubbleColor = isActiveHint ? AppColors.pink : AppColors.secondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/template_mascot.png',
          width: 110,
          height: 110,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox(width: 0),
        ),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            transform: Matrix4.translationValues(6, 0, 0),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: bubbleColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: bubbleColor.withOpacity(0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: bubbleColor.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              _hintText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'ArialRounded',
                fontSize: 15,
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

  String _hintText() => mascotHintText(hintLevel, randomPress);
}

/// Shared mascot line so the speech bubble and the TTS voice stay in sync.
String mascotHintText(int hintLevel, bool randomPress) {
  if (randomPress) {
    return 'فكرة مثيرة! 🤔 لكن لننظر إلى النمط مرة أخرى';
  }

  if (hintLevel >= 4) {
    return 'انظر إلى الجزء المميّز… النمط يعيد نفسه، فما الذي يأتي بعده؟ ✨';
  }

  if (hintLevel >= 3) {
    return 'أعتقد أن هذا الجزء يعيد نفسه… 🔁';
  }

  if (hintLevel >= 1) {
    return 'انتبه جيدًا… الأشكال تتكرر بترتيب معيّن 👀';
  }

  return 'هل ترى شيئًا يتكرر؟';
}