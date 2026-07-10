import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/sound_tracker/sound_tracker_cubit.dart';
import '../../cubits/activities/sound_tracker/sound_tracker_state.dart';
import '../../screens/qr_scanner/qr_scanner_screen.dart';
import '../../services/activities/sound_tracker_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import 'sound_tracker_result_screen.dart';
import 'widgets/multi_section_scan_widget.dart';
import 'widgets/voice_player_widget.dart';

class SoundTrackerVoiceScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int? startLevelNumber;

  const SoundTrackerVoiceScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SoundTrackerCubit()
        ..loadGame(
          activityId: activityId,
          activitySessionId: activitySessionId,
          childId: childId,
          sessionId: sessionId,
          startLevelId: startLevelId,
          startLevelNumber: startLevelNumber,
        ),
      child: SoundTrackerVoiceView(
        activityId: activityId,
        childId: childId,
        sessionId: sessionId,
      ),
    );
  }
}

class SoundTrackerVoiceView extends StatefulWidget {
  final int activityId;
  final int childId;
  final int sessionId;

  const SoundTrackerVoiceView({
    super.key,
    required this.activityId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<SoundTrackerVoiceView> createState() => _SoundTrackerVoiceViewState();
}

class _SoundTrackerVoiceViewState extends State<SoundTrackerVoiceView> {
  final ScrollController _scrollController = ScrollController();

  int? _activeLevelId;
  bool _showMultiScanSections = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncLevelUi(SoundTrackerLoaded state) {
    if (_activeLevelId == state.level.id) return;

    _activeLevelId = state.level.id;
    _showMultiScanSections = false;
  }

  Future<void> _openSingleQrScanner(BuildContext context) async {
    final String? scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(
          returnFirstScan: true,
        ),
      ),
    );

    if (!mounted) return;

    if (scannedValue == null || scannedValue.trim().isEmpty) return;

    await context.read<SoundTrackerCubit>().onQrScanned(
      scannedValue.trim(),
    );
  }

  void _unlockMultiScanSections() {
    if (_showMultiScanSections) {
      _scrollToBottom();
      return;
    }

    setState(() {
      _showMultiScanSections = true;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<SoundTrackerCubit, SoundTrackerState>(
        listener: (context, state) {
          if (state is SoundTrackerError) {
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

          if (state is SoundTrackerResult) {
            _openResultScreen(context, state);
          }

          if (state is SoundTrackerActivityComplete) {
            // Completion has already been shown through the unified
            // correct-answer screen. Return directly to the roadmap.
            Navigator.of(context).pop();
          }
        },
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

  void _openResultScreen(
      BuildContext context,
      SoundTrackerResult state,
      ) {
    final previousState = state.previousState;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (resultContext) {
          return SoundTrackerResultScreen(
            isCorrect: state.isCorrect,
            levelNumber: previousState.currentLevelNumber,
            totalLevels: previousState.totalLevels,
            isLastLevel: previousState.isLastLevel,
            message: state.message,
            onRetryPressed: () {
              Navigator.of(resultContext).pop();
              context.read<SoundTrackerCubit>().retryCurrentLevel();
            },
            onContinuePressed: () {
              Navigator.of(resultContext).pop();

              if (previousState.isLastLevel) {
                Navigator.of(context).pop();
                return;
              }

              context.read<SoundTrackerCubit>().goToNextLevel();
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SoundTrackerState state) {
    if (state is SoundTrackerInitial || state is SoundTrackerLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is SoundTrackerError) {
      return _ErrorView(
        message: state.message,
        onRetry: () {
          Navigator.of(context).pop();
        },
      );
    }

    if (state is SoundTrackerLevelComplete) {
      return _LevelCompleteView(
        message: state.message,
      );
    }

    if (state is SoundTrackerResult) {
      return _buildLoadedView(context, state.previousState);
    }

    if (state is SoundTrackerLoaded) {
      return _buildLoadedView(context, state);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadedView(
      BuildContext context,
      SoundTrackerLoaded state,
      ) {
    _syncLevelUi(state);

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
            child: ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              children: [
                _MascotInstructionCard(state: state),
                const SizedBox(height: 20),
                VoicePlayerWidget(
                  key: ValueKey('sound_tracker_audio_${state.level.id}'),
                  audioUrl: state.level.audioUrl,
                  audioFinished: state.audioFinished,
                  onAudioFinished: () {
                    context.read<SoundTrackerCubit>().onAudioFinished();
                  },
                  onNext: () {
                    if (state.isMultiSection) {
                      _unlockMultiScanSections();
                    } else {
                      _openSingleQrScanner(context);
                    }
                  },
                  title:
                  state.sectionCount == 1 ? 'المقطع الصوتي' : 'استمع للمقطع',
                  subtitle: state.sectionCount == 1
                      ? 'استمع للصوت ثم امسح البطاقة المناسبة.'
                      : 'استمع للأصوات ثم امسح البطاقات بالترتيب.',
                ),
                if (state.isMultiSection && _showMultiScanSections) ...[
                  const SizedBox(height: 20),
                  MultiSectionScanWidget(
                    sectionCount: state.sectionCount,
                    expectedSequence: state.level.expectedSequence,
                    sectionAnswered: state.sectionAnswered,
                    sectionCorrect: state.sectionCorrect,
                    onSectionScanned: (sectionIndex, scannedValue) {
                      return context.read<SoundTrackerCubit>().onSectionScanned(
                        sectionIndex: sectionIndex,
                        result: scannedValue,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MascotInstructionCard extends StatelessWidget {
  final SoundTrackerLoaded state;

  const _MascotInstructionCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 92,
          child: Image.asset(
            'assets/images/template_mascot.png',
            height: 132,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.emoji_emotions_rounded,
                size: 82,
                color: AppColors.primary,
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 132,
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'تتبّع الأصوات',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _instructionText(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                _SmallChip(
                  text:
                  'المستوى ${state.currentLevelNumber} من ${state.totalLevels}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _instructionText() {
    if (state.sectionCount == 1) {
      return 'اسمع الصوت جيدًا، ثم اختر البطاقة المطابقة.';
    }

    return 'اسمع المقطع كاملًا، ثم امسح البطاقات بنفس ترتيب الأصوات.';
  }
}

class _SmallChip extends StatelessWidget {
  final String text;

  const _SmallChip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.075),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.white.withOpacity(0.85),
          width: 1.1,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12.8,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          height: 1.0,
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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 58,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'جاري فتح المستوى التالي...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 58,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 26,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'رجوع',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 17,
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
        ),
      ],
    );
  }
}