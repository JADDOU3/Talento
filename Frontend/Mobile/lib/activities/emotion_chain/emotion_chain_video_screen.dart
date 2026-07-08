import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_cubit.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_state.dart';
import '../../shared/layout/app_background.dart';
import 'emotion_chain_ar.dart';
import 'emotion_chain_result_screen.dart';
import 'emotion_chain_step_screen.dart';
import 'widgets/emotion_chain_video_player.dart';
import '../../shared/layout/top_bar.dart';

/// Host screen for the whole Emotion Chain run.
///
/// It owns the cubit and renders the correct view for each state:
/// VideoPlaying -> video, StepReady -> step view, StepResult -> result view,
/// LevelComplete / ActivityComplete -> summary. The QR scanner is the only
/// thing pushed as a separate route (it returns the scanned value).
class EmotionChainVideoScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const EmotionChainVideoScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EmotionChainCubit>(
      create: (_) => EmotionChainCubit()
        ..loadGame(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
        ),
      child: const _EmotionChainView(),
    );
  }
}

class _EmotionChainView extends StatelessWidget {
  const _EmotionChainView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmotionChainCubit, EmotionChainState>(
      builder: (context, state) {
        if (state is EmotionChainStepReady) {
          return EmotionChainStepView(state: state);
        }
        if (state is EmotionChainStepResult) {
          return EmotionChainResultView(state: state);
        }
        if (state is EmotionChainVideoPlaying) {
          return _VideoView(state: state);
        }
        if (state is EmotionChainLevelComplete) {
          return _MessageScreen(
            icon: Icons.emoji_events_rounded,
            title: 'أحسنت! أنهيت المستوى',
            subtitle: 'المستوى التالي قادم...',
            showSpinner: true,
          );
        }
        if (state is EmotionChainActivityComplete) {
          return _MessageScreen(
            icon: Icons.celebration_rounded,
            title: 'رائع! أكملت السلسلة كاملة 🎉',
            subtitle: 'لقد بنيت سلسلة المشاعر بالكامل!',
            actionLabel: 'العودة للخريطة',
            onAction: () => Navigator.of(context).pop(),
          );
        }
        if (state is EmotionChainError) {
          return _MessageScreen(
            icon: Icons.error_outline_rounded,
            title: 'صار في خطأ',
            subtitle: state.message,
            actionLabel: 'رجوع',
            onAction: () => Navigator.of(context).pop(),
          );
        }
        // Initial / Loading
        return const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AppBackground(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        );
      },
    );
  }
}

class _VideoView extends StatelessWidget {
  final EmotionChainVideoPlaying state;

  const _VideoView({required this.state});

  @override
  Widget build(BuildContext context) {
    final challenge = state.videoChallenge;
    final prompt = EmotionChainAr.prompt(original: challenge.prompt);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TopBar(
                leadingIcon: Icons.arrow_back_ios_new_rounded,
                onLeadingPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        EmotionChainVideoPlayer(
                          url: challenge.url,
                          prompt: prompt,
                          onFinished: () => context
                              .read<EmotionChainCubit>()
                              .onVideoFinished(),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          prompt,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'ArialRounded',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _MessageScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Column(
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
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 88,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'DGAgnadeen',
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'ArialRounded',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (showSpinner)
                            const CircularProgressIndicator(),
                          if (actionLabel != null && onAction != null)
                            SizedBox(
                              width: double.infinity,
                              child: Material(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(22),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: onAction,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    child: Text(
                                      actionLabel!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'DGAgnadeen',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}