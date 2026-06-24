import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/color_lab/color_lab_models.dart';

/// Shows the CHOICE palette image LARGE, with invisible tap zones overlaid on
/// each paint-tube so tapping a tube picks its color.
class ColorPaletteWidget extends StatelessWidget {
  final ColorLabImage? paletteImage;
  final ValueChanged<ColorLabPaletteColor> onColorPicked;

  const ColorPaletteWidget({
    super.key,
    required this.paletteImage,
    required this.onColorPicked,
  });

  @override
  Widget build(BuildContext context) {
    final slots = (paletteImage?.slots ?? 0) > 0 ? paletteImage!.slots : 5;
    final colors = _resolveColors(slots);
    final hasImage = paletteImage != null && paletteImage!.hasImage;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1.9, // big, prominent palette
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                      ? Image.network(
                    paletteImage!.url,
                    fit: BoxFit.cover, // fills the whole area → big
                    errorBuilder: (_, __, ___) => _fallbackTray(colors),
                  )
                      : _fallbackTray(colors),
                ),

                // Invisible tap zones — one column per color
                for (int i = 0; i < colors.length; i++)
                  Positioned(
                    left: (w / colors.length) * i,
                    top: 0,
                    width: w / colors.length,
                    height: h,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onColorPicked(colors[i]),
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<ColorLabPaletteColor> _resolveColors(int slots) {
    final fromMeta = paletteImage?.paletteColors ?? const [];
    if (fromMeta.isNotEmpty) return fromMeta;

    const fallback = [
      ColorLabPaletteColor(name: 'أحمر', hex: '#FF0000', rgb: [255, 0, 0]),
      ColorLabPaletteColor(name: 'أزرق', hex: '#0066FF', rgb: [0, 102, 255]),
      ColorLabPaletteColor(name: 'أصفر', hex: '#FFD60A', rgb: [255, 214, 10]),
      ColorLabPaletteColor(name: 'أبيض', hex: '#FFFFFF', rgb: [255, 255, 255]),
      ColorLabPaletteColor(name: 'أسود', hex: '#000000', rgb: [0, 0, 0]),
    ];
    return fallback.take(slots).toList();
  }

  Widget _fallbackTray(List<ColorLabPaletteColor> colors) {
    return Container(
      color: const Color(0xFFE8D5B5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: colors.map((c) => _Tube(color: c.color)).toList(),
      ),
    );
  }
}

class _Tube extends StatelessWidget {
  final Color color;
  const _Tube({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        Container(
          width: 38,
          height: 90,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
