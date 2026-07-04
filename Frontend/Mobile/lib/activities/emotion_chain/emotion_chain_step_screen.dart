import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_cubit.dart';
import '../../cubits/activities/emotion_chain/emotion_chain_state.dart';
import '../../shared/layout/app_background.dart';
import 'emotion_chain_ar.dart';
import 'widgets/chain_progress_bar.dart';
import 'widgets/emotion_chain_scanner_screen.dart';
import 'widgets/timer_bar_widget.dart';

/// The step view: chain progress, optional timer, chainStep badge, optional
/// character label, prompt recap, question, and the Scan Card button.
class EmotionChainStepView extends StatelessWidget {
  final EmotionChainStepReady state;

  const EmotionChainStepView({super.key, required this.state});

  static const Map<String, String> _stepLabels = {
    'feeling': 'المشاعر',
    'action': 'التصرّف',
    'outcome': 'النتيجة',
  };

  Future<void> _scan(BuildContext context) async {
    final cubit = context.read<EmotionChainCubit>();
    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const EmotionChainScannerScreen()),
    );
    if (scanned != null && scanned.isNotEmpty) {
      cubit.onQrScanned(scanned);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = state.challenge;
    final isTimeUp = state.isTimeUp;
    final stepLabel = _stepLabels[challenge.chainStep] ?? challenge.chainStep;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ChainProgressBar(
                    steps: state.level.chainSteps,
                    currentIndex: state.currentChallengeIndex,
                    characters:
                        state.level.challenges.map((c) => c.character).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (state.hasTimer && state.timerRemaining != null) ...[
                    TimerBarWidget(
                      totalSeconds: state.timerSeconds!,
                      remainingSeconds: state.timerRemaining!,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // chainStep badge
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        stepLabel,
                        style: const TextStyle(
                          fontFamily: 'DGAgnadeen',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                  if (challenge.hasCharacter) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'الطفل ${challenge.character}',
                          style: TextStyle(
                            fontFamily: 'ArialRounded',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Prompt recap
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      EmotionChainAr.prompt(original: challenge.prompt),
                      style: const TextStyle(
                        fontFamily: 'ArialRounded',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question
                  Text(
                    EmotionChainAr.question(
                      original: challenge.question,
                      chainStep: challenge.chainStep,
                      character: challenge.character,
                    ),
                    style: const TextStyle(
                      fontFamily: 'DGAgnadeen',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Scan Card button (disabled when time is up)
                  _ScanButton(
                    enabled: !isTimeUp,
                    onTap: () => _scan(context),
                  ),

                  if (isTimeUp) ...[
                    const SizedBox(height: 12),
                    Text(
                      'انتهى الوقت!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ArialRounded',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _ScanButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.qr_code_scanner_rounded, color: AppColors.white),
                SizedBox(width: 10),
                Text(
                  'امسح البطاقة',
                  style: TextStyle(
                    fontFamily: 'DGAgnadeen',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
