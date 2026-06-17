import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/story_spinner/story_spinner_cubit.dart';
import '../../cubits/activities/story_spinner/story_spinner_state.dart';
import '../../models/activities/story_spinner/story_spinner_level_model.dart';
import '../../shared/layout/app_background.dart';
import 'story_spinner_story_screen.dart';
import 'widgets/spin_wheel_widget.dart';

class StorySpinnerWheelScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const StorySpinnerWheelScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StorySpinnerCubit()
        ..loadGame(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
        ),
      child: const StorySpinnerWheelView(),
    );
  }
}

class StorySpinnerWheelView extends StatefulWidget {
  const StorySpinnerWheelView({super.key});

  @override
  State<StorySpinnerWheelView> createState() => _StorySpinnerWheelViewState();
}

class _StorySpinnerWheelViewState extends State<StorySpinnerWheelView> {
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<StorySpinnerCubit, StorySpinnerState>(
        listener: (context, state) {
          if (state is StorySpinnerError) {
            setState(() {
              _isConfirming = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  textDirection: TextDirection.rtl,
                ),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: AppBackground(
              child: SafeArea(
                child: _buildBody(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StorySpinnerState state) {
    if (state is StorySpinnerInitial || state is StorySpinnerLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StorySpinnerError) {
      return _ErrorView(message: state.message);
    }

    if (state is StorySpinnerLoaded) {
      return _LoadedWheelView(
        state: state,
        isConfirming: _isConfirming,
        onNext: _goToStoryScreen,
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Future<void> _goToStoryScreen(StorySpinnerLoaded state) async {
    if (_isConfirming || !state.allWheelsLanded || state.isSpinning) return;

    setState(() {
      _isConfirming = true;
    });

    final cubit = context.read<StorySpinnerCubit>();

    await cubit.onWheelsConfirmed();

    if (!mounted) return;

    final currentState = cubit.state;

    if (currentState is! StorySpinnerLoaded) {
      setState(() {
        _isConfirming = false;
      });
      return;
    }

    if (!currentState.allWheelsLanded) {
      setState(() {
        _isConfirming = false;
      });
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: StorySpinnerStoryScreen(
            characterIcon: currentState.characterIcon!,
            eventIcon: currentState.eventIcon!,
            placeIcon: currentState.placeIcon!,
          ),
        ),
      ),
    ).then((_) {
      if (!mounted) return;

      setState(() {
        _isConfirming = false;
      });
    });
  }
}

class _LoadedWheelView extends StatelessWidget {
  final StorySpinnerLoaded state;
  final bool isConfirming;
  final void Function(StorySpinnerLoaded state) onNext;

  const _LoadedWheelView({
    required this.state,
    required this.isConfirming,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final characterChallenge = state.level.spinChallengeForStep('character');
    final eventChallenge = state.level.spinChallengeForStep('event');
    final placeChallenge = state.level.spinChallengeForStep('place');

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      children: [
        _TopInfoBar(elapsed: state.elapsed),
        const SizedBox(height: 16),
        _HeaderCard(),
        const SizedBox(height: 16),
        if (characterChallenge != null)
          SpinWheelWidget(
            label: 'Character',
            question: _questionOrFallback(
              characterChallenge,
              'Who is in your story?',
            ),
            icons: characterChallenge.icons,
            landedIcon: state.characterIcon,
            isSpinning: state.isSpinning && state.spinningStep == 'character',
            onSpin: () {
              context.read<StorySpinnerCubit>().onSpinStarted('character');
            },
            onLanded: (icon) {
              context
                  .read<StorySpinnerCubit>()
                  .onSpinLanded('character', icon);
            },
          ),
        if (characterChallenge != null) const SizedBox(height: 14),
        if (eventChallenge != null)
          SpinWheelWidget(
            label: 'Event',
            question: _questionOrFallback(
              eventChallenge,
              'What happens in your story?',
            ),
            icons: eventChallenge.icons,
            landedIcon: state.eventIcon,
            isSpinning: state.isSpinning && state.spinningStep == 'event',
            onSpin: () {
              context.read<StorySpinnerCubit>().onSpinStarted('event');
            },
            onLanded: (icon) {
              context.read<StorySpinnerCubit>().onSpinLanded('event', icon);
            },
          ),
        if (eventChallenge != null) const SizedBox(height: 14),
        if (placeChallenge != null)
          SpinWheelWidget(
            label: 'Place',
            question: _questionOrFallback(
              placeChallenge,
              'Where does your story happen?',
            ),
            icons: placeChallenge.icons,
            landedIcon: state.placeIcon,
            isSpinning: state.isSpinning && state.spinningStep == 'place',
            onSpin: () {
              context.read<StorySpinnerCubit>().onSpinStarted('place');
            },
            onLanded: (icon) {
              context.read<StorySpinnerCubit>().onSpinLanded('place', icon);
            },
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed:
            state.allWheelsLanded && !state.isSpinning && !isConfirming
                ? () => onNext(state)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              foregroundColor: AppColors.white,
              elevation: state.allWheelsLanded ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: isConfirming
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.white,
                ),
              ),
            )
                : const Icon(Icons.arrow_back_rounded),
            label: Text(
              isConfirming ? 'جاري التحضير...' : 'Next',
              style: AppTextStyles.button.copyWith(
                fontFamily: 'DGAgnadeen',
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _questionOrFallback(
      StorySpinnerChallengeModel challenge,
      String fallback,
      ) {
    final question = challenge.question.trim();

    if (question.isNotEmpty) return question;

    return fallback;
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.28),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'لفّي العجلات الثلاث، وبعدها احكي قصتك بالعناصر اللي طلعت معك.',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
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
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Row(
      children: [
        _CircleButton(
          icon: Icons.arrow_forward_ios_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
          child: Text(
            '$minutes:$seconds',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.error,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}