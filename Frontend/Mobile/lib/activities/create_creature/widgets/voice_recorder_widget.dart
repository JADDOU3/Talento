// import 'package:audioplayers/audioplayers.dart' as ap;
// import 'package:flutter/material.dart';
//
// class VoiceRecorderWidget extends StatefulWidget {
//   final void Function(String filePath) onRecordingComplete;
//   final bool isRecording;
//   final VoidCallback onToggleRecording;
//   final Duration recordingDuration;
//   final String? recordedFilePath;
//
//   const VoiceRecorderWidget({
//     super.key,
//     required this.onRecordingComplete,
//     required this.isRecording,
//     required this.onToggleRecording,
//     this.recordingDuration = Duration.zero,
//     this.recordedFilePath,
//   });
//
//   @override
//   State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
// }
//
// class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
//   final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
//
//   bool _isPlaying = false;
//   Duration _playbackPosition = Duration.zero;
//   Duration _playbackTotal = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (mounted) {
//         setState(() => _isPlaying = state == ap.PlayerState.playing);
//       }
//     });
//
//     _audioPlayer.onPositionChanged.listen((pos) {
//       if (mounted) setState(() => _playbackPosition = pos);
//     });
//
//     _audioPlayer.onDurationChanged.listen((dur) {
//       if (mounted) setState(() => _playbackTotal = dur);
//     });
//
//     _audioPlayer.onPlayerComplete.listen((_) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _playbackPosition = Duration.zero;
//         });
//       }
//     });
//   }
//
//   @override
//   void didUpdateWidget(VoiceRecorderWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.isRecording && _isPlaying) {
//       _audioPlayer.stop();
//     }
//
//     if (widget.recordedFilePath != oldWidget.recordedFilePath) {
//       _audioPlayer.stop();
//       setState(() {
//         _isPlaying = false;
//         _playbackPosition = Duration.zero;
//         _playbackTotal = Duration.zero;
//       });
//     }
//   }
//
//   Future<void> _togglePlayback() async {
//     final path = widget.recordedFilePath;
//     if (path == null) return;
//
//     if (_isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.play(ap.DeviceFileSource(path));
//     }
//   }
//
//   String _formatDuration(Duration d) {
//     final minutes = d.inMinutes.toString().padLeft(2, '0');
//     final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final recordedPath = widget.recordedFilePath;
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         GestureDetector(
//           onTap: widget.onToggleRecording,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: widget.isRecording
//                   ? Colors.red
//                   : Theme.of(context).primaryColor,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: (widget.isRecording
//                           ? Colors.red
//                           : Theme.of(context).primaryColor)
//                       .withValues(alpha: 0.4),
//                   blurRadius: 16,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Icon(
//               widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
//               color: Colors.white,
//               size: 36,
//             ),
//           ),
//         ),
//         const SizedBox(height: 12),
//         if (widget.isRecording)
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.circle, color: Colors.red, size: 10),
//               const SizedBox(width: 6),
//               Text(
//                 _formatDuration(widget.recordingDuration),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.red,
//                 ),
//               ),
//             ],
//           )
//         else
//           Text(
//             recordedPath == null ? 'اضغط للتسجيل' : 'اضغط للتسجيل من جديد',
//             style: const TextStyle(fontSize: 20, color: Colors.grey),
//           ),
//         if (recordedPath != null && !widget.isRecording) ...[
//           const SizedBox(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: _togglePlayback,
//                 icon: Icon(
//                   _isPlaying
//                       ? Icons.pause_circle_filled
//                       : Icons.play_circle_filled,
//                   size: 48,
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ],
//           ),
//           if (_playbackTotal > Duration.zero) ...[
//             Slider(
//               value: _playbackPosition.inSeconds
//                   .clamp(0, _playbackTotal.inSeconds)
//                   .toDouble(),
//               max: _playbackTotal.inSeconds.toDouble(),
//               onChanged: (val) async {
//                 await _audioPlayer.seek(Duration(seconds: val.toInt()));
//               },
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _formatDuration(_playbackPosition),
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 Text(
//                   _formatDuration(_playbackTotal),
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ],
//     );
//   }
// } //OLD VOICE RECORDER


// import 'package:audioplayers/audioplayers.dart' as ap;
// import 'package:flutter/material.dart';
//
// class VoiceRecorderWidget extends StatefulWidget {
//   final void Function(String filePath) onRecordingComplete;
//   final bool isRecording;
//   final VoidCallback onToggleRecording;
//   final Duration recordingDuration;
//   final String? recordedFilePath;
//
//   const VoiceRecorderWidget({
//     super.key,
//     required this.onRecordingComplete,
//     required this.isRecording,
//     required this.onToggleRecording,
//     this.recordingDuration = Duration.zero,
//     this.recordedFilePath,
//   });
//
//   @override
//   State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
// }
//
// class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
//   final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
//
//   bool _isPlaying = false;
//   Duration _playbackPosition = Duration.zero;
//   Duration _playbackTotal = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (mounted) {
//         setState(() => _isPlaying = state == ap.PlayerState.playing);
//       }
//     });
//
//     _audioPlayer.onPositionChanged.listen((pos) {
//       if (mounted) setState(() => _playbackPosition = pos);
//     });
//
//     _audioPlayer.onDurationChanged.listen((dur) {
//       if (mounted) setState(() => _playbackTotal = dur);
//     });
//
//     _audioPlayer.onPlayerComplete.listen((_) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _playbackPosition = Duration.zero;
//         });
//       }
//     });
//   }
//
//   @override
//   void didUpdateWidget(VoiceRecorderWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.isRecording && _isPlaying) {
//       _audioPlayer.stop();
//     }
//
//     if (widget.recordedFilePath != oldWidget.recordedFilePath) {
//       _audioPlayer.stop();
//       setState(() {
//         _isPlaying = false;
//         _playbackPosition = Duration.zero;
//         _playbackTotal = Duration.zero;
//       });
//     }
//   }
//
//   Future<void> _togglePlayback() async {
//     final path = widget.recordedFilePath;
//     if (path == null) return;
//
//     if (_isPlaying) {
//       await _audioPlayer.pause();
//     } else {
//       await _audioPlayer.play(ap.DeviceFileSource(path));
//     }
//   }
//
//   String _formatDuration(Duration d) {
//     final minutes = d.inMinutes.toString().padLeft(2, '0');
//     final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$seconds';
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final recordedPath = widget.recordedFilePath;
//     final hasRecording = recordedPath != null;
//
//     final displayDuration = widget.isRecording
//         ? widget.recordingDuration
//         : (hasRecording ? _playbackTotal : Duration.zero);
//
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Top row: timer + mic icon
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 _formatDuration(displayDuration),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF0F6E56),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: widget.onToggleRecording,
//                 child: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE1F5EE),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
//                     color: const Color(0xFF0F6E56),
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           // Decorative dot row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(10, (i) {
//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 3),
//                 width: 6,
//                 height: 6,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFB6E2D3),
//                   shape: BoxShape.circle,
//                 ),
//               );
//             }),
//           ),
//           const SizedBox(height: 20),
//           // Bottom row: play + record buttons
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed:
//                   hasRecording && !widget.isRecording ? _togglePlayback : null,
//                   style: OutlinedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     side: const BorderSide(color: Color(0xFFE0E0E0)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(28),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'تشغيل',
//                         style: TextStyle(
//                           color: hasRecording ? Colors.black87 : Colors.grey,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       Icon(
//                         _isPlaying ? Icons.pause : Icons.play_arrow,
//                         size: 18,
//                         color: hasRecording ? Colors.black87 : Colors.grey,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 flex: 2,
//                 child: ElevatedButton(
//                   onPressed: widget.onToggleRecording,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFE24B7E),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(28),
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         widget.isRecording
//                             ? 'إيقاف'
//                             : (hasRecording ? 'إعادة التسجيل' : 'ابدأ التسجيل'),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Icon(
//                         widget.isRecording
//                             ? Icons.stop_rounded
//                             : Icons.fiber_manual_record,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }NEW OLD WODFET


import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final void Function(
      String filePath,
      Duration recordingDuration,
      ) onRecordingComplete;
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

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  late final AnimationController _waveController;

  bool _isPlaying = false;
  Duration _playbackPosition = Duration.zero;
  Duration _playbackTotal = Duration.zero;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == ap.PlayerState.playing);
        _syncWaveController();
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
        _syncWaveController();
      }
    });
  }

  void _syncWaveController() {
    final shouldAnimate = widget.isRecording || _isPlaying;
    if (shouldAnimate && !_waveController.isAnimating) {
      _waveController.repeat();
    } else if (!shouldAnimate && _waveController.isAnimating) {
      _waveController.stop();
      _waveController.reset();
    }
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

    _syncWaveController();
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
    _waveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordedPath = widget.recordedFilePath;
    final hasRecording = recordedPath != null;

    final displayDuration = widget.isRecording
        ? widget.recordingDuration
        : (hasRecording ? _playbackTotal : Duration.zero);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(displayDuration),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F6E56),
                ),
              ),
              GestureDetector(
                onTap: widget.onToggleRecording,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE1F5EE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: const Color(0xFF0F6E56),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Animated dot row
          SizedBox(
            height: 24,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                final active = widget.isRecording || _isPlaying;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(10, (i) {
                    double heightFactor = 0.3;
                    if (active) {
                      final phase = (_waveController.value * 2 * math.pi) + (i * 0.6);
                      heightFactor = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(phase));
                    }
                    final dotHeight = 6 + 16 * heightFactor;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: dotHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB6E2D3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  hasRecording && !widget.isRecording ? _togglePlayback : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE0E0E0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'تشغيل',
                        style: TextStyle(
                          color: hasRecording ? Colors.black87 : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 18,
                        color: hasRecording ? Colors.black87 : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onToggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE24B7E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.isRecording
                            ? 'إيقاف'
                            : (hasRecording ? 'إعادة التسجيل' : 'ابدأ التسجيل'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.isRecording
                            ? Icons.stop_rounded
                            : Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
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