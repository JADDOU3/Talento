import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

/// Autoplaying video for the story step.
/// - If [url] is null/empty -> shows the prompt placeholder and calls
///   [onFinished] immediately.
/// - If the video errors out -> falls back to [onFinished] so the flow never
///   gets stuck.
/// - On normal completion -> calls [onFinished].
class EmotionChainVideoPlayer extends StatefulWidget {
  final String? url;
  final String prompt;
  final VoidCallback onFinished;

  const EmotionChainVideoPlayer({
    super.key,
    required this.url,
    required this.prompt,
    required this.onFinished,
  });

  @override
  State<EmotionChainVideoPlayer> createState() =>
      _EmotionChainVideoPlayerState();
}

class _EmotionChainVideoPlayerState extends State<EmotionChainVideoPlayer> {
  VideoPlayerController? _controller;
  bool _finished = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.url;
    if (url == null || url.trim().isEmpty) {
      // No video -> behave as if it ended right away.
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      controller.addListener(_onTick);
      await controller.initialize();
      if (!mounted) return;
      setState(() => _ready = true);
      await controller.play();
    } catch (_) {
      _finish();
    }
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || _finished) return;
    final value = controller.value;
    if (value.hasError) {
      _finish();
      return;
    }
    if (value.isInitialized &&
        value.duration > Duration.zero &&
        value.position >= value.duration) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (controller != null && _ready) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio == 0
              ? 16 / 9
              : controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      );
    }

    // Placeholder while loading OR when there is no video.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.movie_rounded, size: 54, color: AppColors.primary),
          const SizedBox(height: 14),
          Text(
            widget.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
