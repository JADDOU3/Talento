import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final void Function(String filePath) onRecordingComplete;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    required this.isRecording,
    required this.onToggleRecording,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Timer? _timer;
  StreamSubscription<void>? _playerCompleteSubscription;

  Duration _recordingDuration = Duration.zero;
  String? _lastRecordingPath;
  bool _isPreviewPlaying = false;
  bool _isStartingOrStopping = false;

  @override
  void initState() {
    super.initState();

    _playerCompleteSubscription = _player.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPreviewPlaying = false;
      });
    });
  }

  @override
  void didUpdateWidget(covariant VoiceRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isRecording && widget.isRecording) {
      _startRecording();
      return;
    }

    if (oldWidget.isRecording && !widget.isRecording) {
      _stopRecording();
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _playerCompleteSubscription?.cancel();
    _player.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_isStartingOrStopping) return;

    setState(() {
      _isStartingOrStopping = true;
      _recordingDuration = Duration.zero;
      _isPreviewPlaying = false;
    });

    try {
      await _player.stop();

      final hasPermission = await _recorder.hasPermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'لازم نسمح باستخدام المايكروفون عشان نسجل القصة',
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

        widget.onToggleRecording();
        return;
      }

      final filePath =
          '${Directory.systemTemp.path}/story_spinner_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _startTimer();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر بدء التسجيل: $error',
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }

      widget.onToggleRecording();
    } finally {
      if (mounted) {
        setState(() {
          _isStartingOrStopping = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    if (_isStartingOrStopping) return;

    setState(() {
      _isStartingOrStopping = true;
    });

    try {
      _stopTimer();

      final path = await _recorder.stop();

      if (path != null && path.trim().isNotEmpty) {
        _lastRecordingPath = path;
        widget.onRecordingComplete(path);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر حفظ التسجيل: $error',
              textDirection: TextDirection.rtl,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStartingOrStopping = false;
        });
      }
    }
  }

  Future<void> _togglePlayback() async {
    final path = _lastRecordingPath;

    if (path == null || path.trim().isEmpty) return;

    if (_isPreviewPlaying) {
      await _player.stop();

      if (!mounted) return;

      setState(() {
        _isPreviewPlaying = false;
      });

      return;
    }

    await _player.play(DeviceFileSource(path));

    if (!mounted) return;

    setState(() {
      _isPreviewPlaying = true;
    });
  }

  void _startTimer() {
    _stopTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _recordingDuration += const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final hasRecording = _lastRecordingPath != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: widget.isRecording
              ? AppColors.red.withOpacity(0.26)
              : AppColors.primary.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isRecording
                      ? AppColors.red.withOpacity(0.12)
                      : AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isRecording
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  color: widget.isRecording ? AppColors.red : AppColors.primary,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.isRecording
                      ? 'التسجيل شغال... احكي قصتك'
                      : hasRecording
                      ? 'تم حفظ التسجيل، فيك تسمعيه أو تعيدي التسجيل'
                      : 'سجلي قصة قصيرة باستخدام العناصر الثلاثة',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _formatDuration(_recordingDuration),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: widget.isRecording ? AppColors.red : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RecordingBars(isRecording: widget.isRecording),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isStartingOrStopping ? null : widget.onToggleRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      widget.isRecording ? AppColors.red : AppColors.pink,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor: AppColors.white,
                      elevation: _isStartingOrStopping ? 0 : 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: Icon(
                      widget.isRecording
                          ? Icons.stop_rounded
                          : Icons.fiber_manual_record_rounded,
                    ),
                    label: Text(
                      widget.isRecording ? 'Stop' : 'Record',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: hasRecording && !widget.isRecording
                      ? _togglePlayback
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    disabledForegroundColor: AppColors.hint,
                    side: BorderSide(
                      color: hasRecording && !widget.isRecording
                          ? AppColors.primary.withOpacity(0.45)
                          : AppColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: Icon(
                    _isPreviewPlaying
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _isPreviewPlaying ? 'Stop' : 'Play',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: hasRecording && !widget.isRecording
                          ? AppColors.primary
                          : AppColors.hint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordingBars extends StatelessWidget {
  final bool isRecording;

  const _RecordingBars({
    required this.isRecording,
  });

  @override
  Widget build(BuildContext context) {
    final heights = [12.0, 22.0, 16.0, 28.0, 18.0, 24.0, 14.0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(heights.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 240 + (index * 25)),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: isRecording ? heights[index] : 10,
          decoration: BoxDecoration(
            color: isRecording
                ? AppColors.red.withOpacity(0.72)
                : AppColors.primary.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}