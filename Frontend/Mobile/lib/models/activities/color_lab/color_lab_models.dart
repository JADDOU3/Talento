import 'dart:convert';

import 'package:flutter/material.dart';

/// ===================== LEVEL =====================
/// One level of the Color Lab activity. Contains one CHOICE image
/// (the palette) and multiple TARGET images (the challenges).
class ColorLabLevel {
  final int id;
  final int levelNumber;
  final int difficulty;
  final String description;
  final List<ColorLabImage> images;

  const ColorLabLevel({
    required this.id,
    required this.levelNumber,
    required this.difficulty,
    required this.description,
    required this.images,
  });

  factory ColorLabLevel.fromJson(Map<String, dynamic> json) {
    return ColorLabLevel(
      id: _toInt(json['id']),
      levelNumber: _toInt(json['levelNumber']),
      difficulty: _toInt(json['difficulty']),
      description: (json['description'] ?? '').toString(),
      images: _parseImages(json['images']),
    );
  }

  /// The single palette image for this level (role == CHOICE).
  ColorLabImage? get paletteImage {
    for (final img in images) {
      if (img.isChoice) return img;
    }
    return null;
  }

  /// All target challenges (role == TARGET), sorted by sortOrder.
  List<ColorLabImage> get challenges {
    final targets = images.where((img) => img.isTarget).toList();
    targets.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return targets;
  }

  /// Level-type detection, kept in one place.
  ///
  /// Palette-mix mode (Part 1): the level has a CHOICE image (the palette).
  /// Free-coloring mode (Level 4): no CHOICE image — every image is TARGET.
  bool get isFreeColoring => paletteImage == null && challenges.isNotEmpty;

  static List<ColorLabImage> _parseImages(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => ColorLabImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <ColorLabImage>[];
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// ===================== IMAGE =====================
/// A single image inside a level. Either CHOICE (palette) or TARGET (object).
class ColorLabImage {
  final int id;
  final String s3Key;
  final String url;
  final String role; // CHOICE | TARGET
  final String label;
  final String description;
  final int sortOrder;
  final Map<String, dynamic> meta;

  const ColorLabImage({
    required this.id,
    required this.s3Key,
    required this.url,
    required this.role,
    required this.label,
    required this.description,
    required this.sortOrder,
    required this.meta,
  });

  factory ColorLabImage.fromJson(Map<String, dynamic> json) {
    return ColorLabImage(
      id: _toInt(json['id']),
      s3Key: (json['s3Key'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      role: (json['role'] ?? '').toString().toUpperCase(),
      label: (json['label'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      sortOrder: _toInt(json['sortOrder']),
      meta: _parseMeta(json['meta']),
    );
  }

  bool get isChoice => role == 'CHOICE';
  bool get isTarget => role == 'TARGET';
  bool get hasImage => url.trim().isNotEmpty;

  /// CHOICE only: number of color tap zones on the palette.
  int get slots => _toInt(meta['slots']);

  /// CHOICE only: the available colors on the palette (if backend provides them).
  /// Falls back to empty — coordinates/colors can be supplied by design team.
  List<ColorLabPaletteColor> get paletteColors {
    final raw = meta['colors'] ?? meta['palette'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) =>
          ColorLabPaletteColor.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <ColorLabPaletteColor>[];
  }

  /// TARGET only: the target color(s) the child must match.
  List<ColorLabTargetColor> get targetColors {
    // Accept several possible key spellings from the backend.
    final raw = meta['targetColors'] ??
        meta['targetColor'] ??
        meta['target_colors'] ??
        meta['colors'] ??
        meta['color'];

    if (raw is List) {
      final parsed = raw
          .whereType<Map>()
          .map((e) =>
          ColorLabTargetColor.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.hex.isNotEmpty || c.rgb.isNotEmpty)
          .toList();
      if (parsed.isNotEmpty) return parsed;
    }
    if (raw is Map) {
      return [
        ColorLabTargetColor.fromJson(Map<String, dynamic>.from(raw)),
      ];
    }
    if (raw is String && raw.trim().isNotEmpty) {
      // meta value is just a hex string or a color name
      return [
        ColorLabTargetColor(
          name: raw.startsWith('#') ? '' : raw,
          hex: raw.startsWith('#') ? raw : (_namedHex(raw) ?? ''),
          rgb: const [],
        ),
      ];
    }

    // Last resort: infer from the challenge label (e.g. "banana" → yellow).
    final inferred = _inferFromLabel();
    if (inferred != null) return [inferred];

    return <ColorLabTargetColor>[];
  }

  /// Maps a known object/color label to its expected color.
  ColorLabTargetColor? _inferFromLabel() {
    final l = label.trim().toLowerCase();
    const map = {
      // Level 1 — single colors
      'banana': ['yellow', '#FFD60A', 255, 214, 10],
      'موز': ['yellow', '#FFD60A', 255, 214, 10],
      'موزة': ['yellow', '#FFD60A', 255, 214, 10],
      'sky': ['blue', '#4DA6FF', 77, 166, 255],
      'سماء': ['blue', '#4DA6FF', 77, 166, 255],
      'apple': ['red', '#E83A2F', 232, 58, 47],
      'تفاحة': ['red', '#E83A2F', 232, 58, 47],
      'leaf': ['green', '#3FA535', 63, 165, 53],
      'ورقة': ['green', '#3FA535', 63, 165, 53],
      // Level 2 — mixed colors
      'orange': ['orange', '#FF8C00', 255, 140, 0],
      'برتقال': ['orange', '#FF8C00', 255, 140, 0],
      'برتقالة': ['orange', '#FF8C00', 255, 140, 0],
      'carrot': ['orange', '#FF8C00', 255, 140, 0],
      'جزرة': ['orange', '#FF8C00', 255, 140, 0],
      'grape': ['purple', '#8000FF', 128, 0, 255],
      'عنب': ['purple', '#8000FF', 128, 0, 255],
      'eggplant': ['purple', '#8000FF', 128, 0, 255],
      'باذنجان': ['purple', '#8000FF', 128, 0, 255],
      // direct color names
      'yellow': ['yellow', '#FFD60A', 255, 214, 10],
      'red': ['red', '#FF0000', 255, 0, 0],
      'blue': ['blue', '#0066FF', 0, 102, 255],
      'green': ['green', '#3FA535', 63, 165, 53],
      'أصفر': ['yellow', '#FFD60A', 255, 214, 10],
      'أحمر': ['red', '#FF0000', 255, 0, 0],
      'أزرق': ['blue', '#0066FF', 0, 102, 255],
      'أخضر': ['green', '#3FA535', 63, 165, 53],
    };
    final v = map[l];
    if (v == null) return null;
    return ColorLabTargetColor(
      name: v[0] as String,
      hex: v[1] as String,
      rgb: [v[2] as int, v[3] as int, v[4] as int],
    );
  }

  String? _namedHex(String name) {
    const named = {
      'red': '#FF0000',
      'yellow': '#FFD60A',
      'blue': '#0066FF',
      'green': '#22A722',
      'white': '#FFFFFF',
      'black': '#000000',
      'orange': '#FF8C00',
      'purple': '#8000FF',
    };
    return named[name.trim().toLowerCase()];
  }

  /// TARGET only: primary target color (first one).
  ColorLabTargetColor? get primaryTarget =>
      targetColors.isNotEmpty ? targetColors.first : null;

  static Map<String, dynamic> _parseMeta(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    // Backend may send meta as a JSON-encoded string → decode it.
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // not JSON — ignore
      }
    }
    return <String, dynamic>{};
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// ===================== TARGET COLOR =====================
/// The color the child is trying to match, from a TARGET image's meta.
class ColorLabTargetColor {
  final String name;
  final String hex;
  final List<int> rgb;

  const ColorLabTargetColor({
    required this.name,
    required this.hex,
    required this.rgb,
  });

  factory ColorLabTargetColor.fromJson(Map<String, dynamic> json) {
    return ColorLabTargetColor(
      name: (json['name'] ?? '').toString(),
      hex: (json['hex'] ?? '').toString(),
      rgb: _parseRgb(json['rgb'], json['hex']),
    );
  }

  Color get color => _hexToColor(hex, rgb);

  static List<int> _parseRgb(dynamic rgbValue, dynamic hexValue) {
    if (rgbValue is List && rgbValue.length >= 3) {
      return [
        _clamp(rgbValue[0]),
        _clamp(rgbValue[1]),
        _clamp(rgbValue[2]),
      ];
    }
    // fall back to parsing hex
    final c = _hexToColor(hexValue?.toString() ?? '', const []);
    return [c.red, c.green, c.blue];
  }

  static int _clamp(dynamic v) {
    final n = (v is int) ? v : int.tryParse(v.toString()) ?? 0;
    return n.clamp(0, 255);
  }
}

/// ===================== PALETTE COLOR =====================
/// One selectable color on the CHOICE palette image.
class ColorLabPaletteColor {
  final String name;
  final String hex;
  final List<int> rgb;

  const ColorLabPaletteColor({
    required this.name,
    required this.hex,
    required this.rgb,
  });

  factory ColorLabPaletteColor.fromJson(Map<String, dynamic> json) {
    return ColorLabPaletteColor(
      name: (json['name'] ?? '').toString(),
      hex: (json['hex'] ?? '').toString(),
      rgb: ColorLabTargetColor._parseRgb(json['rgb'], json['hex']),
    );
  }

  Color get color => _hexToColor(hex, rgb);
}

/// ===================== HELPERS =====================
Color _hexToColor(String hex, List<int> fallbackRgb) {
  var cleaned = hex.trim().replaceAll('#', '');
  if (cleaned.length == 6) {
    final value = int.tryParse('FF$cleaned', radix: 16);
    if (value != null) return Color(value);
  }
  if (cleaned.length == 8) {
    final value = int.tryParse(cleaned, radix: 16);
    if (value != null) return Color(value);
  }
  if (fallbackRgb.length >= 3) {
    return Color.fromARGB(
      255,
      fallbackRgb[0],
      fallbackRgb[1],
      fallbackRgb[2],
    );
  }
  return const Color(0xFFCCCCCC);
}

/// ===================== COLOR MIXING =====================
/// Mixes paint colors so the result looks realistic and pretty (not the muddy
/// grey you get from a plain RGB average).
///
/// Strategy:
/// 1. If the picked colors match a known recipe (e.g. red+yellow), return the
///    nice canonical result (orange) directly.
/// 2. Otherwise blend using a subtractive (CMYK-style) model, which keeps
///    mixes vivid instead of washing them out to grey.
class ColorMixer {
  /// Returns the mixed RGB of the given palette colors.
  static List<int> mix(List<ColorLabPaletteColor> colors) {
    if (colors.isEmpty) return [255, 255, 255];
    if (colors.length == 1) {
      final c = colors.first.color;
      return [c.red, c.green, c.blue];
    }

    // 1) Recipe match (order-independent) by canonical color names.
    final names = colors.map((c) => _canon(c.name)).toList()..sort();
    final recipeKey = names.join('+');
    final recipe = _recipes[recipeKey];
    if (recipe != null) return recipe;

    // 2) Subtractive blend via CMY.
    return _subtractiveMix(colors);
  }

  static Color mixColor(List<ColorLabPaletteColor> colors) {
    final rgb = mix(colors);
    return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
  }

  // Canonical nice results for the classic kid-friendly combos.
  static const Map<String, List<int>> _recipes = {
    'red+yellow': [255, 140, 0], // orange
    'blue+red': [128, 0, 200], // purple
    'blue+yellow': [52, 199, 89], // green
    'green+yellow': [154, 205, 50], // yellow-green
    'blue+green': [0, 150, 160], // teal
    'red+white': [255, 150, 150], // pink
    'blue+white': [135, 206, 235], // light blue / sky
    'white+yellow': [255, 240, 150], // light yellow
    'green+white': [167, 230, 170], // light green (light leaf)
    'red+black': [140, 0, 0], // dark red
    'black+blue': [0, 40, 110], // dark blue
    'black+green': [20, 90, 40], // dark green
    'black+white': [128, 128, 128], // grey
    'white+white': [255, 255, 255],
  };

  /// Subtractive mixing: convert each color to CMY, average in CMY, convert
  /// back. This mimics mixing pigments and avoids grey mud.
  static List<int> _subtractiveMix(List<ColorLabPaletteColor> colors) {
    double c = 0, m = 0, y = 0;
    for (final col in colors) {
      final rgb = col.color;
      c += 1 - rgb.red / 255.0;
      m += 1 - rgb.green / 255.0;
      y += 1 - rgb.blue / 255.0;
    }
    final n = colors.length;
    c /= n;
    m /= n;
    y /= n;

    final r = ((1 - c) * 255).round().clamp(0, 255);
    final g = ((1 - m) * 255).round().clamp(0, 255);
    final b = ((1 - y) * 255).round().clamp(0, 255);
    return [r, g, b];
  }

  static String _canon(String name) {
    final n = name.trim().toLowerCase();
    const map = {
      'أصفر': 'yellow', 'اصفر': 'yellow', 'yellow': 'yellow',
      'أحمر': 'red', 'احمر': 'red', 'red': 'red',
      'أزرق': 'blue', 'ازرق': 'blue', 'blue': 'blue',
      'أخضر': 'green', 'اخضر': 'green', 'green': 'green',
      'أبيض': 'white', 'ابيض': 'white', 'white': 'white',
      'أسود': 'black', 'اسود': 'black', 'black': 'black',
    };
    return map[n] ?? n;
  }
}
