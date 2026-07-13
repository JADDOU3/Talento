import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/empathy_mirror/empathy_mirror_cubit.dart';
import '../../cubits/activities/empathy_mirror/empathy_mirror_state.dart';
import '../../screens/qr_scanner/widgets/camera_viewfinder.dart';
import '../../services/activities/empathy_mirror_service.dart';
import '../../shared/layout/app_background.dart';
import 'empathy_mirror_result_screen.dart';
import 'widgets/card_choices_widget.dart';
import 'widgets/split_character_screen.dart';
import 'widgets/video_player_widget.dart';
import '../../shared/layout/top_bar.dart';

class EmpathyMirrorVideoScreen extends StatelessWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const EmpathyMirrorVideoScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EmpathyMirrorCubit(
        service: EmpathyMirrorService(),
        activityId: activityId,
        activitySessionId: activitySessionId,
        childId: childId,
        sessionId: sessionId,
        startLevelId: startLevelId,
        initialLevelNumber: startLevelNumber,
      )..loadGame(),
      child: const _EmpathyMirrorView(),
    );
  }
}

class _EmpathyMirrorView extends StatelessWidget {
  const _EmpathyMirrorView();

  Future<bool> _onWillPop(BuildContext context) async {
    await context.read<EmpathyMirrorCubit>().logExitIfNotCompleted();
    return true;
  }

  Future<void> _openQrScanner(BuildContext context) async {
    final cubit = context.read<EmpathyMirrorCubit>();
    final String? scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => const _SimpleQrScannerScreen()),
    );
    if (scannedValue != null && context.mounted) {
      cubit.onQrScanned(scannedValue);
    }
  }

  Future<void> _openQrForCharacter(
      BuildContext context, int characterIndex) async {
    final cubit = context.read<EmpathyMirrorCubit>();
    final String? scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (_) => const _SimpleQrScannerScreen()),
    );
    if (scannedValue != null && context.mounted) {
      cubit.onCharacterScanned(characterIndex, scannedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EmpathyMirrorCubit, EmpathyMirrorState>(
      listener: (context, state) async {
        if (state is EmpathyMirrorChallengeResult) {
          // Show result screen then call nextChallenge
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmpathyMirrorResultScreen(
                isCorrect: state.isCorrect,
                onNext: () => Navigator.pop(context),
              ),
            ),
          );
          if (context.mounted) {
            context.read<EmpathyMirrorCubit>().nextChallenge();
          }
        }

        if (state is EmpathyMirrorLevelComplete) {
          // The final correct-answer screen was already shown.
          // Pressing "التالي" now returns directly to the roadmap.
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      builder: (context, state) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: WillPopScope(
            onWillPop: () => _onWillPop(context),
            child: Scaffold(
              backgroundColor: AppColors.background,
              body: AppBackground(
                child: _buildBody(context, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EmpathyMirrorState state) {
    if (state is EmpathyMirrorLoading || state is EmpathyMirrorInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is EmpathyMirrorError) {
      return _buildError(context, state.message);
    }

    final loaded = state is EmpathyMirrorLoaded
        ? state
        : (state is EmpathyMirrorChallengeResult ? state.snapshot : null);

    if (loaded == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Level 3 — split screen
    debugPrint(
        'LEVEL DETECT | levelNumber=${loaded.level.levelNumber} '
            'challenges=${loaded.level.challenges.length} '
            'isLevel2=${loaded.isLevel2} isLevel3=${loaded.isLevel3} '
            'types=${loaded.level.challenges.map((c) => c.type).toList()} '
            'characters=${loaded.level.challenges.map((c) => c.character).toList()}');

    if (loaded.isLevel3) {
      // The shared intro video/scene (no "character" tag) — shown once at
      // the top. The two character panels each get their own question.
      final introChallenge = loaded.level.introChallenge;
      final char1Challenge = loaded.level.challengeForCharacter(1);
      final char2Challenge = loaded.level.challengeForCharacter(2);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBar(
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            onLeadingPressed: () async {
              await _onWillPop(context);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SplitCharacterScreen(
                        videoUrl: introChallenge?.hasVideo == true
                            ? introChallenge!.url
                            : null,
                        videoPrompt: introChallenge?.prompt ?? '',
                        character1Question: char1Challenge?.question ?? '',
                        character2Question: char2Challenge?.question ?? '',
                        onScanCharacter1: () => _openQrForCharacter(context, 1),
                        onScanCharacter2: () => _openQrForCharacter(context, 2),
                        character1Done: loaded.character1Answered,
                        character1Correct: loaded.character1Correct,
                        character2Done: loaded.character2Answered,
                        character2Correct: loaded.character2Correct,
                        videoFinished: loaded.videoFinished,
                        onVideoFinished: () =>
                            context.read<EmpathyMirrorCubit>().onVideoFinished(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Level 2 — on-screen choices
    if (loaded.isLevel2) {
      return _buildLevel2(context, loaded);
    }

    // Levels 1, 4, 5 — video + QR
    return _buildVideoQrLevel(context, loaded);
  }

  // ─── Level 1 / 4 / 5 ──────────────────────────────────────────────────────

  Widget _buildVideoQrLevel(
      BuildContext context,
      EmpathyMirrorLoaded loaded,
      ) {
    final challenge = loaded.currentChallenge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () async {
            await _onWillPop(context);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),

                  _buildProgressBar(loaded),
                  const SizedBox(height: 18),

                  VideoPlayerWidget(
                    key: ValueKey(
                      'vid-${loaded.currentChallengeIndex}-${loaded.videoFinished}',
                    ),
                    videoUrl: challenge.hasVideo ? challenge.url : null,
                    promptText: challenge.prompt,
                    onVideoFinished: () =>
                        context.read<EmpathyMirrorCubit>().onVideoFinished(),
                  ),
                  const SizedBox(height: 18),

                  if (challenge.question.isNotEmpty) ...[
                    _buildQuestionCard(challenge.question),
                    const SizedBox(height: 20),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openQrScanner(context),
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('امسح البطاقة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.read<EmpathyMirrorCubit>().replayVideo(),
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('إعادة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yellow,
                            foregroundColor: AppColors.white,
                            minimumSize: const Size(double.infinity, 54),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: AppTextStyles.button.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Green progress bar under the header (like the design).
  Widget _buildProgressBar(EmpathyMirrorLoaded loaded) {
    final total = loaded.level.challenges.length;
    final current = loaded.currentChallengeIndex + 1;
    final progress = total > 0 ? current / total : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        valueColor:
        const AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  /// Question card. [title] is the small header chip text; pass null to hide it
  /// (used for QR levels where there are no on-screen cards to choose).
  Widget _buildQuestionCard(String question, {String? title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.yellow.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_rounded,
                            color: AppColors.yellow, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.yellow,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                // The question itself — wrapped LTR so English punctuation
                // (?, .) renders on the correct side.
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    question,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Twinky mascot beside the card
        Image.asset(
          'assets/images/template_mascot.png',
          width: 78,
          height: 78,
          errorBuilder: (_, __, ___) => const Text(
            '🤖',
            style: TextStyle(fontSize: 56),
          ),
        ),
      ],
    );
  }

  // ─── Level 2 ───────────────────────────────────────────────────────────────

  Widget _buildLevel2(BuildContext context, EmpathyMirrorLoaded loaded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () async {
            await _onWillPop(context);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: _Level2Body(
              loaded: loaded,
              key: ValueKey(
                'lvl2-${loaded.currentChallengeIndex}-${loaded.attemptNumber}',
              ),
              header: _buildHeader(context),
              questionCardBuilder: (q) => _buildQuestionCard(
                q,
                title: 'اختر البطاقة المناسبة',
              ),
            ),
          ),
        ),
      ],
    );
  }
  // ─── Shared ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final state = context.read<EmpathyMirrorCubit>().state;
    final loaded = state is EmpathyMirrorLoaded
        ? state
        : (state is EmpathyMirrorChallengeResult ? state.snapshot : null);

    final levelNumber = loaded?.level.levelNumber ?? 1;
    final challengeIndex = loaded?.currentChallengeIndex ?? 0;
    final totalChallenges = loaded?.level.challenges.length ?? 1;

    final levelInfo = _levelInfo(levelNumber);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.yellow,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    levelInfo['name']!,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    levelInfo['subtitle']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            '${challengeIndex + 1} / $totalChallenges',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
  /// Arabic level name + subtitle + emoji per level number.
  Map<String, String> _levelInfo(int levelNumber) {
    const levels = {
      1: {
        'name': 'مشاعري',
        'subtitle': 'لاحظ الشعور وتفهمه',
        'emoji': '🎭',
      },
      2: {
        'name': 'لماذا؟',
        'subtitle': 'افهم سبب المشاعر',
        'emoji': '💭',
      },
      3: {
        'name': 'من عيونهم',
        'subtitle': 'شاهد القصة بنظرتهم',
        'emoji': '👀',
      },
      4: {
        'name': 'ماذا ستفعل؟',
        'subtitle': 'اختر تصرفك الصح',
        'emoji': '🤔',
      },
      5: {
        'name': 'أفضل نهاية',
        'subtitle': 'أكمل القصة بشكل إيجابي',
        'emoji': '⭐',
      },
    };
    return levels[levelNumber] ??
        {
          'name': 'مستوى $levelNumber',
          'subtitle': 'استمر في التعلم',
          'emoji': '🌟',
        };
  }


  Widget _buildError(BuildContext context, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TopBar(
          leadingIcon: Icons.arrow_back_ios_new_rounded,
          onLeadingPressed: () async {
            await _onWillPop(context);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        Expanded(
          child: SafeArea(
            top: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 52,
                      color: AppColors.hint,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<EmpathyMirrorCubit>().loadGame(),
                      child: const Text('إعادة المحاولة'),
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

/// Level 2 body — tracks the selected card and shows a Submit button.
/// The child must SELECT a card, then press Submit to answer.
class _Level2Body extends StatefulWidget {
  final EmpathyMirrorLoaded loaded;
  final Widget header;
  final Widget Function(String question) questionCardBuilder;

  const _Level2Body({
    super.key,
    required this.loaded,
    required this.header,
    required this.questionCardBuilder,
  });

  @override
  State<_Level2Body> createState() => _Level2BodyState();
}

class _Level2BodyState extends State<_Level2Body> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final loaded = widget.loaded;
    final challenge = loaded.currentChallenge;
    final isFollowup = challenge.isFollowup;

    // No real video player yet, so cards are always usable.
    const cardsEnabled = true;
    final canSubmit = _selected != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.header,
          const SizedBox(height: 12),

          if (!isFollowup) ...[
            VideoPlayerWidget(
              videoUrl: challenge.hasVideo ? challenge.url : null,
              promptText: challenge.prompt,
              onVideoFinished: () =>
                  context.read<EmpathyMirrorCubit>().onVideoFinished(),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                challenge.prompt,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (challenge.question.isNotEmpty) ...[
            widget.questionCardBuilder(challenge.question),
            const SizedBox(height: 20),
          ],

          Opacity(
            opacity: cardsEnabled ? 1.0 : 0.45,
            child: IgnorePointer(
              ignoring: !cardsEnabled,
              child: CardChoicesWidget(
                choices: loaded.currentChoices,
                onSelectionChanged: (icon) =>
                    setState(() => _selected = icon),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Submit button — enabled only after a card is selected.
          Opacity(
            opacity: canSubmit ? 1.0 : 0.45,
            child: ElevatedButton.icon(
              onPressed: canSubmit
                  ? () => context
                  .read<EmpathyMirrorCubit>()
                  .onCardSelected(_selected!)
                  : null,
              icon: const Icon(Icons.check_rounded),
              label: const Text('تأكيد الإجابة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
                textStyle: AppTextStyles.button
                    .copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Single-scan QR screen: pops with the first scanned value.
/// Also has a "تجربة" button to simulate a scan for testing without a camera.
class _SimpleQrScannerScreen extends StatefulWidget {
  const _SimpleQrScannerScreen();

  @override
  State<_SimpleQrScannerScreen> createState() =>
      _SimpleQrScannerScreenState();
}

class _SimpleQrScannerScreenState extends State<_SimpleQrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcode =
    capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final value = barcode?.rawValue?.trim();
    if (value == null || value.isEmpty) return;

    _handled = true;
    Navigator.pop(context, value);
  }

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
                onLeadingPressed: () => Navigator.pop(context, null),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      children: [
                        Text(
                          'امسح البطاقة',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 22),

                        CameraViewfinder(
                          scannerController: _controller,
                          onDetect: _onDetect,
                          isScannerStopped: false,
                          hasReachedMaxScans: false,
                        ),
                        const SizedBox(height: 24),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(
                              context,
                              'TEST_SCAN_${DateTime.now().millisecondsSinceEpoch}',
                            ),
                            icon: const Icon(Icons.check_circle_rounded),
                            label: const Text('تجربة (أي بطاقة)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
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