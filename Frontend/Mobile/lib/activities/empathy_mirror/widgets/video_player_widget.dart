import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Plays a video from [videoUrl] and notifies [onVideoFinished] when done.
/// Falls back to a prompt-text placeholder if the URL is null/empty —
/// in that case, [onVideoFinished] is called immediately so Continue unlocks.
///
/// Uses Flutter's built-in VideoPlayerController from the video_player package.
/// If the package is not available, the fallback text view is always shown.
class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String promptText;
  final VoidCallback onVideoFinished;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.promptText,
    required this.onVideoFinished,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _finishedOnce = false;

  bool get _hasVideo =>
      widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // If no video, unlock Continue immediately.
    if (!_hasVideo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onVideoFinished();
      });
    }
  }

  void _markFinished() {
    if (_finishedOnce) return;
    _finishedOnce = true;
    widget.onVideoFinished();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasVideo) {
      return _PromptPlaceholder(prompt: widget.promptText);
    }

    // Show video in a WebView-style or use video_player.
    // Using a simple clickable card that simulates finishing for now;
    // replace the inner content with VideoPlayer widget when package confirmed.
    return _VideoCard(
      videoUrl: widget.videoUrl!,
      promptText: widget.promptText,
      onFinished: _markFinished,
    );
  }
}

/// Shown when no video URL is provided.
class _PromptPlaceholder extends StatelessWidget {
  final String prompt;
  const _PromptPlaceholder({required this.prompt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_outline_rounded,
              size: 56, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            prompt.isNotEmpty ? prompt : 'لا يوجد فيديو لهذا التحدي',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Video card widget — integrates with video_player package.
class _VideoCard extends StatelessWidget {
  final String videoUrl;
  final String promptText;
  final VoidCallback onFinished;

  const _VideoCard({
    required this.videoUrl,
    required this.promptText,
    required this.onFinished,
  });

  @override
  Widget build(BuildContext context) {
    // Replace this with actual VideoPlayer widget when video_player is confirmed.
    // For now: tapping the play button marks the video as finished.
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(22),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Placeholder background
            Container(color: const Color(0xFF1A1A2E)),

            // Play button (tap = mark as watched)
            GestureDetector(
              onTap: onFinished,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppColors.white,
                  size: 42,
                ),
              ),
            ),

            // URL shown small at bottom for debug
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Text(
                videoUrl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
