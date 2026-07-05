import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/story_spinner/story_spinner_cubit.dart';
import '../../cubits/activities/story_spinner/story_spinner_state.dart';
import '../../models/activities/story_spinner/icon_arabic_labels.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/voice_recorder_widget.dart';
import '../../screens/roadmap/roadmap_screen.dart';

String _cleanStoryIconName(String icon) {
  var clean = icon.trim();

  if (clean.endsWith('.png')) {
    clean = clean.substring(0, clean.length - 4);
  }

  if (clean.contains('/')) {
    clean = clean.split('/').last;
  }

  return clean.trim();
}

String _storyIconArabicLabel(String icon) {
  final cleanIcon = _cleanStoryIconName(icon);

  return iconArabicLabels[cleanIcon] ?? cleanIcon.replaceAll('_', ' ');
}

class StorySpinnerStoryScreen extends StatefulWidget {
  final String characterIcon;
  final String eventIcon;
  final String placeIcon;
  final int currentAttemptId;

  const StorySpinnerStoryScreen({
    super.key,
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
    required this.currentAttemptId,
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
                  'أحسنتِ! تم إنهاء النشاط بنجاح 🎉',
                  textDirection: TextDirection.rtl,
                ),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.of(context).popUntil(
                  (route) =>
              route.settings.name == RoadmapScreen.routeName || route.isFirst,
            );
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

    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
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
        : 'احكي الآن قصة قصيرة باستخدام العناصر الثلاثة.';

    final checkingStory = isCompleting || state.isCompleting;
    final missingKeywords = state.missingKeywords;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        const _TopHeader(),
        const SizedBox(height: 14),
        _StoryElementsCard(
          characterIcon: characterIcon,
          eventIcon: eventIcon,
          placeIcon: placeIcon,
          missingKeywords: missingKeywords,
        ),
        const SizedBox(height: 14),
        _MascotPromptCard(prompt: prompt),
        if (missingKeywords.isNotEmpty) ...[
          const SizedBox(height: 14),
          _VoiceCheckFeedbackCard(missingKeywords: missingKeywords),
        ],
        const SizedBox(height: 14),
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
            onPressed: state.hasRecording && !isRecording && !checkingStory
                ? onDone
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.border,
              foregroundColor: AppColors.white,
              elevation: state.hasRecording ? 4 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            icon: checkingStory
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
              checkingStory ? 'جاري فحص القصة...' : 'إنهاء',
              style: AppTextStyles.button.copyWith(
                fontFamily: 'DGAgnadeen',
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
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

class _StoryElementsCard extends StatelessWidget {
  final String characterIcon;
  final String eventIcon;
  final String placeIcon;
  final List<String> missingKeywords;

  const _StoryElementsCard({
    required this.characterIcon,
    required this.eventIcon,
    required this.placeIcon,
    required this.missingKeywords,
  });

  @override
  Widget build(BuildContext context) {
    final characterKeyword = _storyIconArabicLabel(characterIcon);
    final eventKeyword = _storyIconArabicLabel(eventIcon);
    final placeKeyword = _storyIconArabicLabel(placeIcon);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            AppColors.white.withOpacity(0.97),
            const Color(0xFFFFFCF5).withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.075),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.035),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.075),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.white.withOpacity(0.85),
                width: 1.2,
              ),
            ),
            child: Text(
              'عناصر قصتك',
              style: AppTextStyles.headlineMedium.copyWith(
                fontFamily: 'DGAgnadeen',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StoryElementTile(
                  icon: characterIcon,
                  label: characterKeyword,
                  isMissing: missingKeywords.contains(characterKeyword),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _StoryElementTile(
                  icon: eventIcon,
                  label: eventKeyword,
                  isMissing: missingKeywords.contains(eventKeyword),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _StoryElementTile(
                  icon: placeIcon,
                  label: placeKeyword,
                  isMissing: missingKeywords.contains(placeKeyword),
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
  final bool isMissing;

  const _StoryElementTile({
    required this.icon,
    required this.label,
    required this.isMissing,
  });

  @override
  Widget build(BuildContext context) {
    final cleanIcon = _cleanStoryIconName(icon);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 116,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 9),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMissing
              ? [
            AppColors.red.withOpacity(0.075),
            AppColors.white.withOpacity(0.92),
          ]
              : [
            AppColors.primary.withOpacity(0.055),
            AppColors.white.withOpacity(0.92),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: isMissing
              ? AppColors.red.withOpacity(0.42)
              : AppColors.primary.withOpacity(0.08),
          width: isMissing ? 1.6 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withOpacity(0.88),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.96),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.035),
                          blurRadius: 9,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/cards/$cleanIcon.png',
                        width: 62,
                        height: 62,
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            Icons.image_not_supported_rounded,
                            color: AppColors.primary.withOpacity(0.8),
                            size: 32,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 23,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isMissing
                        ? AppColors.red.withOpacity(0.10)
                        : AppColors.primary.withOpacity(0.055),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12.2,
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                    color: isMissing ? AppColors.red : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (isMissing)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.13),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.88),
                    width: 1.1,
                  ),
                ),
                child: const Icon(
                  Icons.priority_high_rounded,
                  size: 17,
                  color: AppColors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoiceCheckFeedbackCard extends StatelessWidget {
  final List<String> missingKeywords;

  const _VoiceCheckFeedbackCard({
    required this.missingKeywords,
  });

  @override
  Widget build(BuildContext context) {
    final missingText = missingKeywords.join('، ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.red.withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.88),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic_rounded,
              color: AppColors.red,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'قصة حلوة! خلّينا نذكر كمان: $missingText، وبعدها سجّل مرة ثانية.',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotPromptCard extends StatelessWidget {
  final String prompt;

  const _MascotPromptCard({
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          'assets/images/template_mascot.png',
          height: 104,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_emotions_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.92),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(26),
                topLeft: Radius.circular(26),
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              prompt,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.45,
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