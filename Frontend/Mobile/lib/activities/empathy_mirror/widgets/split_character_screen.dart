import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'video_player_widget.dart';

/// Level 3 split-screen layout: video at top, two character panels below.
/// Character 2 is locked until Character 1 is answered correctly.
class SplitCharacterScreen extends StatelessWidget {
  final String? videoUrl;
  final String videoPrompt;
  final String character1Question;
  final String character2Question;
  final VoidCallback onScanCharacter1;
  final VoidCallback onScanCharacter2;
  final bool character1Done;
  final bool character1Correct;
  final bool character2Done;
  final bool character2Correct;
  final VoidCallback onVideoFinished;
  final bool videoFinished;

  const SplitCharacterScreen({
    super.key,
    required this.videoUrl,
    this.videoPrompt = '',
    required this.character1Question,
    required this.character2Question,
    required this.onScanCharacter1,
    required this.onScanCharacter2,
    required this.character1Done,
    required this.character1Correct,
    required this.character2Done,
    required this.character2Correct,
    required this.onVideoFinished,
    required this.videoFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video at top — shows the shared scene/prompt
        VideoPlayerWidget(
          videoUrl: videoUrl,
          promptText: videoPrompt.isNotEmpty ? videoPrompt : character1Question,
          onVideoFinished: onVideoFinished,
        ),
        const SizedBox(height: 16),

        // Split panels
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _CharacterPanel(
                  characterNumber: 1,
                  question: character1Question,
                  done: character1Done,
                  correct: character1Correct,
                  unlocked: true,
                  onScan: onScanCharacter1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CharacterPanel(
                  characterNumber: 2,
                  question: character2Question,
                  done: character2Done,
                  correct: character2Correct,
                  // Only unlock char 2 after char 1 is answered correctly.
                  unlocked: character1Done && character1Correct,
                  onScan: onScanCharacter2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CharacterPanel extends StatelessWidget {
  final int characterNumber;
  final String question;
  final bool done;
  final bool correct;
  final bool unlocked;
  final VoidCallback onScan;

  const _CharacterPanel({
    required this.characterNumber,
    required this.question,
    required this.done,
    required this.correct,
    required this.unlocked,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: done
              ? (correct ? AppColors.primary : AppColors.error)
              : AppColors.border,
          width: done ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Character avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Text(
              '$characterNumber',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Question
          Text(
            question,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Result or scan button
          if (done)
            _ResultBadge(correct: correct, onRetry: correct ? null : onScan)
          else
            _ScanButton(
              unlocked: unlocked,
              onTap: unlocked ? onScan : null,
            ),
        ],
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool correct;
  final VoidCallback? onRetry;

  const _ResultBadge({required this.correct, this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (correct) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.check_circle_rounded,
            color: AppColors.primary, size: 28),
      );
    }

    return Column(
      children: [
        const Icon(Icons.cancel_rounded, color: AppColors.error, size: 28),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 36),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          child: Text(
            'حاول مجدداً',
            style:
            AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ScanButton extends StatelessWidget {
  final bool unlocked;
  final VoidCallback? onTap;

  const _ScanButton({required this.unlocked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
        label: const Text('امسح البطاقة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 40),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTextStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.w900, fontSize: 12),
        ),
      ),
    );
  }
}
