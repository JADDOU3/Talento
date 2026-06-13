import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final String placeholderText;
  final VoidCallback onVideoEnd;
  final VoidCallback onVideoStarted;
  final int replayToken;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.placeholderText,
    required this.onVideoEnd,
    required this.onVideoStarted,
    required this.replayToken,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  bool _isLoading = false;
  bool _hasStarted = false;
  bool _hasEnded = false;
  bool _placeholderNotified = false;

  bool get _hasVideoUrl {
    return widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();

    if (_hasVideoUrl) {
      _setupVideo();
    } else {
      _notifyPlaceholderFinished();
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();

      _hasStarted = false;
      _hasEnded = false;
      _placeholderNotified = false;

      if (_hasVideoUrl) {
        _setupVideo();
      } else {
        _notifyPlaceholderFinished();
      }

      return;
    }

    if (oldWidget.replayToken != widget.replayToken) {
      _replay();
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  Future<void> _setupVideo() async {
    final url = widget.videoUrl?.trim();

    if (url == null || url.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;

    try {
      await controller.initialize();

      controller.addListener(_videoListener);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      await controller.play();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      widget.onVideoEnd();
    }
  }

  void _videoListener() {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying && !_hasStarted) {
      _hasStarted = true;
      widget.onVideoStarted();
    }

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (duration != Duration.zero &&
        position >= duration &&
        !_hasEnded) {
      _hasEnded = true;
      widget.onVideoEnd();
    }
  }

  Future<void> _replay() async {
    final controller = _controller;

    _hasStarted = false;
    _hasEnded = false;

    if (!_hasVideoUrl || controller == null || !controller.value.isInitialized) {
      _notifyPlaceholderFinished();
      return;
    }

    await controller.seekTo(Duration.zero);
    await controller.play();
  }

  void _notifyPlaceholderFinished() {
    if (_placeholderNotified) return;

    _placeholderNotified = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onVideoStarted();
      widget.onVideoEnd();
    });
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) setState(() {});
  }

  void _disposeController() {
    final controller = _controller;

    controller?.removeListener(_videoListener);
    controller?.dispose();

    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasVideoUrl) {
      return _buildPlaceholder();
    }

    if (_isLoading) {
      return _buildLoading();
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        color: AppColors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            Positioned(
              bottom: 16,
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    controller.value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.movie_creation_rounded,
              color: AppColors.primary,
              size: 38,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.placeholderText.trim().isEmpty
                ? 'الفيديو غير متوفر حاليًا'
                : widget.placeholderText,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}