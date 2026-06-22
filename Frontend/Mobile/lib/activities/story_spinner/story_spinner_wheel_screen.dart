import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/story_spinner/story_spinner_cubit.dart';
import '../../cubits/activities/story_spinner/story_spinner_state.dart';
import '../../models/activities/story_spinner/story_spinner_level_model.dart';
import '../../shared/layout/app_background.dart';
import 'story_spinner_story_screen.dart';
import 'widgets/story_slot_machine_widget.dart';

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
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
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

    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
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
            currentAttemptId: currentState.currentAttemptId,
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

class _LoadedWheelView extends StatefulWidget {
  final StorySpinnerLoaded state;
  final bool isConfirming;
  final void Function(StorySpinnerLoaded state) onNext;

  const _LoadedWheelView({
    required this.state,
    required this.isConfirming,
    required this.onNext,
  });

  @override
  State<_LoadedWheelView> createState() => _LoadedWheelViewState();
}

class _LoadedWheelViewState extends State<_LoadedWheelView> {
  bool _isSlotSpinning = false;

  @override
  Widget build(BuildContext context) {
    final characterChallenge =
    widget.state.level.spinChallengeForStep('character');
    final eventChallenge = widget.state.level.spinChallengeForStep('event');
    final placeChallenge = widget.state.level.spinChallengeForStep('place');

    final hasAllChallenges = characterChallenge != null &&
        eventChallenge != null &&
        placeChallenge != null;

    final canGoNext = widget.state.allWheelsLanded &&
        !widget.state.isSpinning &&
        !_isSlotSpinning &&
        !widget.isConfirming;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const _TopHeader(),
        const SizedBox(height: 14),
        const _HeaderCard(),
        const SizedBox(height: 16),
        if (!hasAllChallenges)
          const _MissingChallengesCard()
        else
          StorySlotMachineWidget(
            characterQuestion: _questionOrFallback(
              characterChallenge,
              'من الشخصية؟',
            ),
            eventQuestion: _questionOrFallback(
              eventChallenge,
              'ما الحدث؟',
            ),
            placeQuestion: _questionOrFallback(
              placeChallenge,
              'أين المكان؟',
            ),
            characterIcons: characterChallenge.icons,
            eventIcons: eventChallenge.icons,
            placeIcons: placeChallenge.icons,
            characterLandedIcon: widget.state.characterIcon,
            eventLandedIcon: widget.state.eventIcon,
            placeLandedIcon: widget.state.placeIcon,
            disabled: widget.isConfirming,
            onSpinningChanged: (isSpinning) {
              if (!mounted) return;

              setState(() {
                _isSlotSpinning = isSpinning;
              });
            },
            onStepSpinStarted: (step) {
              context.read<StorySpinnerCubit>().onSpinStarted(step);
            },
            onStepLanded: (step, icon) {
              context.read<StorySpinnerCubit>().onSpinLanded(step, icon);
            },
          ),
        const SizedBox(height: 24),
        _NextButton(
          enabled: canGoNext,
          isLoading: widget.isConfirming,
          onTap: () => widget.onNext(widget.state),
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

class _MissingChallengesCard extends StatelessWidget {
  const _MissingChallengesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.error.withOpacity(0.12),
        ),
      ),
      child: Text(
        'في عناصر ناقصة من إعدادات اللعبة. تأكد أن تحديات الشخصية والحدث والمكان موجودة.',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w800,
          height: 1.35,
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.white.withOpacity(0.92),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 13,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _TopCircleButton(
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),
          const Spacer(),
          Image.asset(
            'assets/icons/logo1.png',
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Text(
                'Talento',
                style: TextStyle(
                  fontFamily: 'BerlinSans',
                  fontSize: 28,
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
    return Material(
      color: AppColors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/template_mascot.png',
            height: 76,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.primary,
                size: 34,
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'اسحب الذراع لتظهر عناصر القصة، ثم استخدمها في تسجيل قصتك.',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _NextButton({
    required this.enabled,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = enabled && !isLoading;

    return Align(
      alignment: Alignment.center,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: canTap || isLoading ? 1 : 0.80,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 200,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: canTap || isLoading
                  ? [
                AppColors.primary.withOpacity(0.96),
                AppColors.primary.withOpacity(0.82),
              ]
                  : [
                AppColors.border.withOpacity(0.82),
                AppColors.border.withOpacity(0.62),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(
              color: canTap || isLoading
                  ? AppColors.white.withOpacity(0.22)
                  : AppColors.white.withOpacity(0.18),
              width: 1.2,
            ),
            boxShadow: canTap || isLoading
                ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.20),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: AppColors.white.withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ]
                : [
              BoxShadow(
                color: AppColors.black.withOpacity(0.025),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: canTap ? onTap : null,
              borderRadius: BorderRadius.circular(999),
              child: Center(
                child: isLoading
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
                    : Text(
                  'التالي',
                  style: AppTextStyles.button.copyWith(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: canTap
                        ? AppColors.white
                        : AppColors.textSecondary.withOpacity(0.58),
                  ),
                ),
              ),
            ),
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