import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final void Function(String filePath) onRecordingComplete;
  final bool isRecording;
  final VoidCallback onToggleRecording;
  final Duration recordingDuration;
  final String? recordedFilePath;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    required this.isRecording,
    required this.onToggleRecording,
    this.recordingDuration = Duration.zero,
    this.recordedFilePath,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackTotal = Duration.zero;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == ap.PlayerState.playing);
      }
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _playbackPosition = pos);
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _playbackTotal = dur);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void didUpdateWidget(VoiceRecorderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isRecording && _isPlaying) {
      _audioPlayer.stop();
    }

    if (widget.recordedFilePath != oldWidget.recordedFilePath) {
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
        _playbackTotal = Duration.zero;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final path = widget.recordedFilePath;
    if (path == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(ap.DeviceFileSource(path));
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordedPath = widget.recordedFilePath;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.onToggleRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.isRecording
                  ? Colors.red
                  : Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isRecording
                          ? Colors.red
                          : Theme.of(context).primaryColor)
                      .withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.isRecording)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 10),
              const SizedBox(width: 6),
              Text(
                _formatDuration(widget.recordingDuration),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          )
        else
          Text(
            recordedPath == null ? 'اضغط للتسجيل' : 'اضغط للتسجيل من جديد',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
        if (recordedPath != null && !widget.isRecording) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _togglePlayback,
                icon: Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  size: 48,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          if (_playbackTotal > Duration.zero) ...[
            Slider(
              value: _playbackPosition.inSeconds
                  .clamp(0, _playbackTotal.inSeconds)
                  .toDouble(),
              max: _playbackTotal.inSeconds.toDouble(),
              onChanged: (val) async {
                await _audioPlayer.seek(Duration(seconds: val.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_playbackPosition),
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  _formatDuration(_playbackTotal),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }
}
