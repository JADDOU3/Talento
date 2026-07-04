import 'package:flutter/material.dart';

import 'creature_face_assets.dart';

class CreatureFaceWidget extends StatelessWidget {
  final String? genderSelection;
  final String? hairColorSelection;
  final String? eyesSelection;
  final String? mouthSelection;
  final String? feelingSelection;
  final double zoom;

  // final String? networkBaseImageUrl;
  // final bool baseImageLoading;

  const CreatureFaceWidget({
    super.key,
    required this.genderSelection,
    required this.hairColorSelection,
    required this.eyesSelection,
    required this.mouthSelection,
    required this.feelingSelection,
    this.zoom = 1.0,
    // this.networkBaseImageUrl,
    // this.baseImageLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final hairAsset = resolveHairAsset(genderSelection, hairColorSelection);
    final feelingAsset = resolveFeelingAsset(feelingSelection, hairColorSelection);

    return ClipRect(
      child: Transform.scale(
        scale: zoom,
        child: AspectRatio(
          aspectRatio: 562 / 517,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/creature/face/face_base.png', fit: BoxFit.contain),

              if (eyesSelection != null && eyesAssets[eyesSelection] != null)
                Image.asset(eyesAssets[eyesSelection]!, fit: BoxFit.contain),
              if (mouthSelection != null && mouthAssets[mouthSelection] != null)
                Image.asset(mouthAssets[mouthSelection]!, fit: BoxFit.contain),
              if (feelingAsset != null)
                Image.asset(feelingAsset, fit: BoxFit.contain),
              if (hairAsset != null)
                Image.asset(hairAsset, fit: BoxFit.contain),
              // if (networkBaseImageUrl != null)
              //   Image.network(
              //     networkBaseImageUrl!,
              //     fit: BoxFit.contain,
              //     errorBuilder: (_, __, ___) =>
              //         Image.asset('assets/images/kit2.png', fit: BoxFit.contain),
              //   )
              // else
              //   Image.asset('assets/images/kit2.png', fit: BoxFit.contain),
              // if (baseImageLoading)
              //   const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}