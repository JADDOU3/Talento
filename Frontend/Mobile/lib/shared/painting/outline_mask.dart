import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One painted stroke: a color and the points the finger passed through
/// (in canvas-local coordinates).
class ColoringStroke {
  final Color color;
  final List<Offset> points;

  const ColoringStroke({required this.color, required this.points});
}

/// Result of comparing the child's coloring against the derived outline.
class ColoringEvaluation {
  /// Did the child color anything at all?
  final bool hasColoring;

  /// Fraction (0..1) of the colored area that fell inside the outline.
  final double insideRatio;

  /// The dominant color the child used, as [r, g, b].
  final List<int> dominantRgb;

  /// False when the outline couldn't be derived reliably (e.g. the image
  /// pixels couldn't be read — CORS on web). Callers should then skip the
  /// inside/outside check and decide on color match alone.
  final bool maskReliable;

  const ColoringEvaluation({
    required this.hasColoring,
    required this.insideRatio,
    required this.dominantRgb,
    required this.maskReliable,
  });

  static const empty = ColoringEvaluation(
    hasColoring: false,
    insideRatio: 0,
    dominantRgb: [0, 0, 0],
    maskReliable: false,
  );
}

/// Derives the paintable region (the inside of a shape) from a blank outline
/// PNG, purely on the frontend — no point list from the backend.
///
/// Handles two common asset styles robustly:
///  * transparent-background silhouette/outline (uses alpha), and
///  * white-background outline (treats near-white as background).
///
/// The technique: classify every cell as background (transparent or near-white)
/// vs foreground (the dark outline / opaque shape), flood-fill the background
/// inward from the four borders, and treat whatever the flood can't reach as
/// "inside" the shape. Falls back to an alpha/!background silhouette if the
/// flood result looks degenerate (e.g. an open outline that leaks).
class OutlineMask {
  final int width;
  final int height;
  final List<bool> _inside;
  final bool reliable;

  const OutlineMask._({
    required this.width,
    required this.height,
    required List<bool> inside,
    required this.reliable,
  }) : _inside = inside;

  /// A mask that treats everything as inside (used when pixels can't be read).
  factory OutlineMask.allInside() =>
      const OutlineMask._(width: 1, height: 1, inside: [true], reliable: false);

  bool isInsideNorm(double nx, double ny) {
    if (!reliable) return true;
    final mx = (nx * width).floor().clamp(0, width - 1);
    final my = (ny * height).floor().clamp(0, height - 1);
    return _inside[my * width + mx];
  }

  /// Builds a mask from a decoded image. Never throws — returns an
  /// all-inside (unreliable) mask if the pixels can't be read.
  static Future<OutlineMask> fromImage(ui.Image image, {int maxDim = 160}) async {
    try {
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (byteData == null) return OutlineMask.allInside();
      final bytes = byteData.buffer.asUint8List();

      final srcW = image.width;
      final srcH = image.height;
      if (srcW <= 0 || srcH <= 0) return OutlineMask.allInside();

      final mw = srcW <= maxDim ? srcW : maxDim;
      final scale = mw / srcW;
      final mh = (srcH * scale).round().clamp(1, maxDim);

      // Classify cells: true = background (transparent or near-white).
      final isBackground = List<bool>.filled(mw * mh, false);
      for (int my = 0; my < mh; my++) {
        final sy = (my / mh * srcH).floor().clamp(0, srcH - 1);
        for (int mx = 0; mx < mw; mx++) {
          final sx = (mx / mw * srcW).floor().clamp(0, srcW - 1);
          final i = (sy * srcW + sx) * 4;
          final r = bytes[i];
          final g = bytes[i + 1];
          final b = bytes[i + 2];
          final a = bytes[i + 3];
          final lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0;
          final bg = a < 32 || (a > 200 && lum > 0.90);
          isBackground[my * mw + mx] = bg;
        }
      }

      final inside = _floodInside(isBackground, mw, mh);
      final insideCount = inside.where((v) => v).length;
      final frac = insideCount / (mw * mh);

      if (frac >= 0.02 && frac <= 0.98) {
        return OutlineMask._(width: mw, height: mh, inside: inside, reliable: true);
      }

      // Fallback: silhouette = anything that isn't background.
      final silhouette = [for (final bg in isBackground) !bg];
      final silCount = silhouette.where((v) => v).length;
      final silFrac = silCount / (mw * mh);
      if (silFrac >= 0.02 && silFrac <= 0.98) {
        return OutlineMask._(
          width: mw,
          height: mh,
          inside: silhouette,
          reliable: true,
        );
      }

      // Couldn't derive anything meaningful.
      return OutlineMask.allInside();
    } catch (_) {
      return OutlineMask.allInside();
    }
  }

  /// Flood-fill background from the four borders; inside = cells not reached.
  static List<bool> _floodInside(List<bool> isBackground, int w, int h) {
    final visited = List<bool>.filled(w * h, false);
    final stack = <int>[];

    void seed(int x, int y) {
      if (x < 0 || y < 0 || x >= w || y >= h) return;
      final idx = y * w + x;
      if (!visited[idx] && isBackground[idx]) {
        visited[idx] = true;
        stack.add(idx);
      }
    }

    for (int x = 0; x < w; x++) {
      seed(x, 0);
      seed(x, h - 1);
    }
    for (int y = 0; y < h; y++) {
      seed(0, y);
      seed(w - 1, y);
    }

    while (stack.isNotEmpty) {
      final idx = stack.removeLast();
      final x = idx % w;
      final y = idx ~/ w;
      seed(x - 1, y);
      seed(x + 1, y);
      seed(x, y - 1);
      seed(x, y + 1);
    }

    // inside = NOT reached by the background flood from the borders.
    return [for (final v in visited) !v];
  }

  /// Compares painted strokes against this mask.
  ColoringEvaluation evaluate(List<ColoringStroke> strokes, Size canvasSize) {
    if (strokes.isEmpty || canvasSize.width <= 0 || canvasSize.height <= 0) {
      return ColoringEvaluation(
        hasColoring: false,
        insideRatio: 0,
        dominantRgb: const [0, 0, 0],
        maskReliable: reliable,
      );
    }

    int inside = 0;
    int total = 0;
    final colorWeight = <int, int>{};

    void sample(Offset p, Color color) {
      final nx = (p.dx / canvasSize.width).clamp(0.0, 1.0);
      final ny = (p.dy / canvasSize.height).clamp(0.0, 1.0);
      if (isInsideNorm(nx, ny)) inside++;
      total++;
      final key = (color.red << 16) | (color.green << 8) | color.blue;
      colorWeight[key] = (colorWeight[key] ?? 0) + 1;
    }

    for (final stroke in strokes) {
      final pts = stroke.points;
      if (pts.isEmpty) continue;
      if (pts.length == 1) {
        sample(pts.first, stroke.color);
        continue;
      }
      for (int i = 0; i < pts.length - 1; i++) {
        final a = pts[i];
        final b = pts[i + 1];
        final dist = (b - a).distance;
        final steps = dist <= 3 ? 1 : (dist / 3).ceil();
        for (int s = 0; s <= steps; s++) {
          final t = s / steps;
          sample(Offset.lerp(a, b, t)!, stroke.color);
        }
      }
    }

    final insideRatio = total > 0 ? inside / total : 0.0;

    final int dominantKey = colorWeight.isEmpty
        ? 0
        : (colorWeight.entries.toList()
              ..sort((x, y) => y.value.compareTo(x.value)))
            .first
            .key;

    return ColoringEvaluation(
      hasColoring: total > 0,
      insideRatio: insideRatio,
      dominantRgb: [
        (dominantKey >> 16) & 0xFF,
        (dominantKey >> 8) & 0xFF,
        dominantKey & 0xFF,
      ],
      maskReliable: reliable,
    );
  }
}
