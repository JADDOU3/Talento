import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/mirror_mind/mirror_mind_cubit.dart';
import '../../cubits/activities/mirror_mind/mirror_mind_state.dart';
import '../../models/activities/mirror_mind/mirror_mind_choice_model.dart';
import '../../shared/layout/app_background.dart';
import 'mirror_mind_result_screen.dart';
import 'widgets/mirror_choices_widget.dart';
import 'widgets/mirror_target_widget.dart';

class MirrorMindGameScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const MirrorMindGameScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MirrorMindCubit()
        ..loadGame(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
        ),
      child: const _MirrorMindGameView(),
    );
  }
}

class _MirrorMindGameView extends StatelessWidget {
  const _MirrorMindGameView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<MirrorMindCubit, MirrorMindState>(
        listener: (context, state) {
          if (state is MirrorMindPartOneComplete) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MirrorMindResultScreen(
                  elapsed: state.elapsed,
                ),
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

  Widget _buildBody(BuildContext context, MirrorMindState state) {
    if (state is MirrorMindLoading || state is MirrorMindInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MirrorMindError) {
      return _ErrorView(message: state.message);
    }

    if (state is MirrorMindChallengeResult) {
      return _FeedbackView(isCorrect: state.isCorrect);
    }

    if (state is MirrorMindLevelComplete) {
      return _LevelCompleteView(message: state.message);
    }

    if (state is MirrorMindLoaded) {
      return _LoadedGameView(state: state);
    }

    return const SizedBox.shrink();
  }
}

class _LoadedGameView extends StatelessWidget {
  final MirrorMindLoaded state;

  const _LoadedGameView({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;
    final selectedChoice = _selectedChoiceOrNull();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
      child: Column(
        children: [
          _TopInfoBar(elapsed: state.elapsed),

          const SizedBox(height: 12),

          _LevelHeader(state: state),

          const SizedBox(height: 14),

          MirrorTargetWidget(
            challenge: challenge,
            selectedChoice: selectedChoice,
          ),

          const SizedBox(height: 18),

          _TonkyHint(
            text: _hintTextForLevel(state.currentLevelIndex),
          ),

          const SizedBox(height: 14),

          MirrorChoicesWidget(
            choices: challenge.choices,
            selectedChoiceIndex: state.selectedChoiceIndex,
            onChoiceSelected: (index) {
              context.read<MirrorMindCubit>().selectChoice(index);
            },
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: state.canSubmit
                  ? () => context.read<MirrorMindCubit>().submitAnswer()
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
    );
  }

  MirrorMindChoiceModel? _selectedChoiceOrNull() {
    final index = state.selectedChoiceIndex;

    if (index == null) return null;
    if (index < 0 || index >= state.challenge.choices.length) return null;

    return state.challenge.choices[index];
  }

  String _hintTextForLevel(int levelIndex) {
    if (levelIndex == 0) {
      return 'إذا كان الشكل هنا… فأين يظهر انعكاسه؟';
    }

    if (levelIndex == 1) {
      return 'انتبه للترتيب! المرآة تعكس أماكن الأشكال.';
    }

    return 'كيف يبدو هذا الاتجاه في المرآة؟';
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
        color: AppColors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 14,
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
    return Material(
      color: AppColors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final MirrorMindLoaded state;

  const _LevelHeader({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _levelTitle(state.currentLevelIndex),
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

  String _levelTitle(int levelIndex) {
    if (levelIndex == 0) {
      return 'المستوى 1 - انعكاس بسيط';
    }

    if (levelIndex == 1) {
      return 'المستوى 2 - عدة أشكال';
    }

    return 'المستوى 3 - اليمين واليسار';
  }
}

class _TonkyHint extends StatelessWidget {
  final String text;

  const _TonkyHint({
    required this.text,
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
            width: 132,
            height: 132,
            fit: BoxFit.contain,
          ),
        ),

        Expanded(
          child: Container(
            transform: Matrix4.translationValues(6, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
              text,
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
}

class _FeedbackView extends StatelessWidget {
  final bool isCorrect;

  const _FeedbackView({
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
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
    return Center(
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
          color: AppColors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'ArialRounded',
            fontSize: 15,
            color: AppColors.red,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  return '$minutes:$seconds';
}