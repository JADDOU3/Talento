import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

TextDirection _smartTextDirection(String value) {
  final arabicCount = RegExp(r'[\u0600-\u06FF]').allMatches(value).length;
  final englishCount = RegExp(r'[A-Za-z]').allMatches(value).length;

  return englishCount > arabicCount ? TextDirection.ltr : TextDirection.rtl;
}

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

    if (duration != Duration.zero && position >= duration && !_hasEnded) {
      _hasEnded = true;
      widget.onVideoEnd();
    }
  }

  Future<void> _replay() async {
    final controller = _controller;

    _hasStarted = false;
    _hasEnded = false;

    if (!_hasVideoUrl || controller == null || !controller.value.isInitialized) {
      _placeholderNotified = false;
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

    return Container(
      decoration: _softCardDecoration(),
      padding: const EdgeInsets.all(7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
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
                bottom: 14,
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.48),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.30),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.white,
                      size: 35,
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

  Widget _buildLoading() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: _softCardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final storyText = widget.placeholderText.trim().isEmpty
        ? 'الفيديو غير متوفر حاليًا، لكن يمكنك قراءة الموقف هنا.'
        : widget.placeholderText.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 208),
      decoration: _softCardDecoration(),
      child: Stack(
        children: [
          const Positioned(
            top: 18,
            left: 18,
            child: _TinySparkle(
              color: AppColors.yellow,
              size: 18,
            ),
          ),
          const Positioned(
            bottom: 18,
            right: 20,
            child: _TinySparkle(
              color: AppColors.pink,
              size: 14,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.55),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.yellow.withValues(alpha: 0.14),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.theater_comedy_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                Directionality(
                  textDirection: _smartTextDirection(storyText),
                  child: Text(
                    storyText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 17,
                      height: 1.42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _softCardDecoration() {
    return BoxDecoration(
      color: AppColors.white.withValues(alpha: 0.90),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: AppColors.white.withValues(alpha: 0.96),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 9),
        ),
        BoxShadow(
          color: AppColors.yellow.withValues(alpha: 0.06),
          blurRadius: 18,
          offset: const Offset(-6, -4),
        ),
      ],
    );
  }
}

class _TinySparkle extends StatelessWidget {
  final Color color;
  final double size;

  const _TinySparkle({
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _TinySparklePainter(color),
    );
  }
}

class _TinySparklePainter extends CustomPainter {
  final Color color;

  const _TinySparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    final path = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(center.dx + size.width * 0.16, center.dy - size.height * 0.16)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx + size.width * 0.16, center.dy + size.height * 0.16)
      ..lineTo(center.dx, size.height)
      ..lineTo(center.dx - size.width * 0.16, center.dy + size.height * 0.16)
      ..lineTo(0, center.dy)
      ..lineTo(center.dx - size.width * 0.16, center.dy - size.height * 0.16)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TinySparklePainter oldDelegate) {
    return false;
  }
}
