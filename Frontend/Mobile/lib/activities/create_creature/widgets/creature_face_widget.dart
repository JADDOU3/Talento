import 'package:flutter/material.dart';

class CreatureFaceWidget extends StatelessWidget {
  final String? eyesSelection;
  final String? mouthSelection;
  final String? feelingSelection;
  final double zoom;

  const CreatureFaceWidget({
    super.key,
    required this.eyesSelection,
    required this.mouthSelection,
    required this.feelingSelection,
    this.zoom = 1.0,//// don't need currently
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Transform.scale(
        scale: zoom,
        child: AspectRatio(
          aspectRatio: 300 / 380,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/face/face_base.png'),
              if (feelingSelection != null)
                Image.asset('assets/images/face/brow_$feelingSelection.png'),
              if (eyesSelection != null)
                Image.asset('assets/images/face/eyes_$eyesSelection.png'),
              if (mouthSelection != null)
                Image.asset('assets/images/face/mouth_$mouthSelection.png'),
            ],
          ),
        ),
      ),
    );
  }
}