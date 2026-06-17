import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/story_spinner/story_spinner_cubit.dart';
import '../../cubits/activities/story_spinner/story_spinner_state.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/voice_recorder_widget.dart';

class StorySpinnerStoryScreen extends StatefulWidget {
  final String characterIcon;
  final String eventIcon;
  final String placeIcon;

  const StorySpinnerStoryScreen({
    super.key,
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
  });

  @override
  State<StorySpinnerStoryScreen> createState() =>
      _StorySpinnerStoryScreenState();
}

class _StorySpinnerStoryScreenState extends State<StorySpinnerStoryScreen> {
  bool _isRecording = false;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<StorySpinnerCubit, StorySpinnerState>(
        listener: (context, state) {
          if (state is StorySpinnerActivityComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'أحسنتِ! تم إنهاء النشاط 🎉',
                  textDirection: TextDirection.rtl,
                ),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.popUntil(context, (route) => route.isFirst);
            return;
          }

          if (state is StorySpinnerError) {
            setState(() {
              _isCompleting = false;
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
    if (state is StorySpinnerLoaded) {
      return _LoadedStoryView(
        state: state,
        characterIcon: widget.characterIcon,
        eventIcon: widget.eventIcon,
        placeIcon: widget.placeIcon,
        isRecording: _isRecording,
        isCompleting: _isCompleting,
        onToggleRecording: _toggleRecording,
        onRecordingComplete: (filePath) {
          context.read<StorySpinnerCubit>().onRecordingComplete(filePath);
        },
        onDone: _done,
      );
    }

    if (state is StorySpinnerError) {
      return _ErrorView(message: state.message);
    }

    return const Center(child: CircularProgressIndicator());
  }

  void _toggleRecording() {
    if (_isCompleting) return;

    setState(() {
      _isRecording = !_isRecording;
    });
  }

  Future<void> _done() async {
    if (_isCompleting || _isRecording) return;

    setState(() {
      _isCompleting = true;
    });

    await context.read<StorySpinnerCubit>().onStoryDone();

    if (!mounted) return;

    final currentState = context.read<StorySpinnerCubit>().state;

    if (currentState is! StorySpinnerActivityComplete) {
      setState(() {
        _isCompleting = false;
      });
    }
  }
}

class _LoadedStoryView extends StatelessWidget {
  final StorySpinnerLoaded state;
  final String characterIcon;
  final String eventIcon;
  final String placeIcon;
  final bool isRecording;
  final bool isCompleting;
  final VoidCallback onToggleRecording;
  final void Function(String filePath) onRecordingComplete;
  final VoidCallback onDone;

  const _LoadedStoryView({
    required this.state,
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
    required this.isRecording,
    required this.isCompleting,
    required this.onToggleRecording,
    required this.onRecordingComplete,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final voiceChallenge = state.level.voiceChallenge;

    final prompt = voiceChallenge?.prompt.trim().isNotEmpty == true
        ? voiceChallenge!.prompt.trim()
        : 'Now tell your story using these three elements.';

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
      children: [
        _TopInfoBar(elapsed: state.elapsed),
        const SizedBox(height: 16),
        _StoryElementsCard(
          characterIcon: characterIcon,
          eventIcon: eventIcon,
          placeIcon: placeIcon,
        ),
        const SizedBox(height: 16),
        _PromptCard(prompt: prompt),
        const SizedBox(height: 16),
        VoiceRecorderWidget(
          isRecording: isRecording,
          onToggleRecording: onToggleRecording,
          onRecordingComplete: onRecordingComplete,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton.icon(
            onPressed: state.hasRecording && !isRecording && !isCompleting
                ? onDone
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              foregroundColor: AppColors.white,
              elevation: state.hasRecording ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: isCompleting
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
                : const Icon(Icons.check_circle_rounded),
            label: Text(
              isCompleting ? 'جاري الإنهاء...' : 'Done',
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
}

class _StoryElementsCard extends StatelessWidget {
  final String characterIcon;
  final String eventIcon;
  final String placeIcon;

  const _StoryElementsCard({
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(32),
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
      child: Column(
        children: [
          Text(
            'Your story elements:',
            style: AppTextStyles.headlineMedium.copyWith(
              fontFamily: 'DGAgnadeen',
              fontSize: 25,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StoryElementTile(
                  icon: characterIcon,
                  label: 'Character',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StoryElementTile(
                  icon: eventIcon,
                  label: 'Event',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StoryElementTile(
                  icon: placeIcon,
                  label: 'Place',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryElementTile extends StatelessWidget {
  final String icon;
  final String label;

  const _StoryElementTile({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/cards/$icon.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Icon(
                  Icons.image_not_supported_rounded,
                  color: AppColors.primary.withOpacity(0.8),
                  size: 34,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final String prompt;

  const _PromptCard({
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.yellow.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.yellow.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.record_voice_over_rounded,
            color: AppColors.pink,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              prompt,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
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