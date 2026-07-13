import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String audioUrl;
  final bool audioFinished;
  final Future<void> Function()? onPlaybackStarted;
  final VoidCallback onAudioFinished;
  final VoidCallback onNext;
  final String title;
  final String subtitle;

  const VoicePlayerWidget({
    super.key,
    required this.audioUrl,
    required this.audioFinished,
    this.onPlaybackStarted,
    required this.onAudioFinished,
    required this.onNext,
    this.title = 'استمع للصوت',
    this.subtitle = 'شغّل الصوت كاملًا، ثم اضغط التالي',
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> {
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completeSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isCompleted = false;
  bool _reportedFinished = false;

  @override
  void initState() {
    super.initState();
    _setupPlayer();
  }

  @override
  void didUpdateWidget(covariant VoicePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.audioUrl != widget.audioUrl) {
      _resetForNewAudio();
    }
  }

  Future<void> _setupPlayer() async {
    await _player.setReleaseMode(ReleaseMode.stop);

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (!mounted) return;

      setState(() {
        _duration = duration;
      });
    });

    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (!mounted) return;

      setState(() {
        _position = position;
      });
    });

    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;

      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _completeSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      if (!_reportedFinished) {
        _reportedFinished = true;
        widget.onAudioFinished();
      }

      setState(() {
        _isPlaying = false;
        _isLoading = false;
        _isCompleted = true;
        _position = _duration;
      });
    });
  }

  Future<void> _resetForNewAudio() async {
    await _player.stop();

    if (!mounted) return;

    setState(() {
      _duration = Duration.zero;
      _position = Duration.zero;
      _isPlaying = false;
      _isLoading = false;
      _isCompleted = false;
      _reportedFinished = false;
    });
  }

  Future<void> _togglePlayPause() async {
    if (widget.audioUrl.trim().isEmpty) {
      _showMessage('رابط الصوت غير متوفر');
      return;
    }

    if (_isLoading) return;

    try {
      if (_isPlaying) {
        await _player.pause();
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await widget.onPlaybackStarted?.call();

      if (_isCompleted) {
        await _player.stop();
        await _player.play(UrlSource(widget.audioUrl));
      } else {
        final hasStarted = _position > Duration.zero;

        if (hasStarted) {
          await _player.resume();
        } else {
          await _player.play(UrlSource(widget.audioUrl));
        }
      }

      if (!mounted) return;

      setState(() {
        _isCompleted = false;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('تعذر تشغيل الصوت');
    }
  }

  Future<void> _seekTo(double value) async {
    final duration = _duration;

    if (duration == Duration.zero) return;

    final newPosition = Duration(milliseconds: value.round());

    await _player.seek(newPosition);

    if (!mounted) return;

    setState(() {
      _position = newPosition;
      _isCompleted = false;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _stateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxMilliseconds = _duration.inMilliseconds.toDouble();
    final currentMilliseconds = _position.inMilliseconds
        .clamp(0, _duration.inMilliseconds)
        .toDouble();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
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
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                fontFamily: 'DGAgnadeen',
                fontSize: 29,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            _buildPlayButton(),
            const SizedBox(height: 20),
            Slider(
              value: maxMilliseconds <= 0 ? 0 : currentMilliseconds,
              min: 0,
              max: maxMilliseconds <= 0 ? 1 : maxMilliseconds,
              onChanged: maxMilliseconds <= 0 ? null : _seekTo,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    final icon = _isLoading
        ? null
        : _isPlaying
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primary.withOpacity(0.82),
              AppColors.secondary,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.white,
            ),
          )
              : Icon(
            icon,
            size: 50,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: widget.audioFinished ? widget.onNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.hint,
          foregroundColor: AppColors.white,
          elevation: widget.audioFinished ? 4 : 0,
          shadowColor: AppColors.primary.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontFamily: 'DGAgnadeen',
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        child: Text(
          widget.audioFinished ? 'التالي' : 'استمع أولًا',
        ),
      ),
    );
  }
}