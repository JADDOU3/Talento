import 'package:flutter/material.dart';

/// Per-level maze geometry, defined MANUALLY by the developer.
///
/// The backend only provides the maze IMAGE — it has no coordinate data for
/// walls, holes, start, or end. The developer overlays coordinates on each
/// level image and fills them in here.
///
/// ALL coordinates are NORMALIZED (0.0–1.0) relative to the rendered image
/// size, so they scale correctly across screen sizes.
class MazeLevelConfig {
  /// Backend level id this config belongs to.
  final int levelId;

  /// Ball spawn position, normalized 0.0–1.0.
  final Offset startPoint;

  /// Win zone center, normalized 0.0–1.0.
  final Offset endPoint;

  /// Win zone radius, normalized relative to image width.
  final double endPointRadius;

  /// Wall collision boxes, normalized 0.0–1.0.
  final List<Rect> wallRects;

  /// Hole zones, normalized 0.0–1.0.
  final List<Rect> holeRects;

  const MazeLevelConfig({
    required this.levelId,
    required this.startPoint,
    required this.endPoint,
    required this.endPointRadius,
    required this.wallRects,
    required this.holeRects,
  });
}

/// مؤقتًا: نفس إحداثيات المستوى الأول مستخدمة للمستوى 2 و 3.
/// هذا يخلي المستويات تفتح وما تعطي error.
/// لاحقًا لو صور المستوى 2 و 3 مختلفة، لازم تقيسي إحداثياتهم وتحطي configs حقيقية.
const List<Rect> _bodilyMazeWallRects = [
  Rect.fromLTWH(0.0091, 0.011, 0.9853, 0.1608),
  Rect.fromLTWH(0.4621, 0.1718, 0.1088, 0.0342),
  Rect.fromLTWH(0.015, 0.1697, 0.1603, 0.0726),
  Rect.fromLTWH(0.8532, 0.1759, 0.1412, 0.1556),
  Rect.fromLTWH(0.6253, 0.2091, 0.1779, 0.083),
  Rect.fromLTWH(0.3826, 0.2506, 0.2427, 0.0467),
  Rect.fromLTWH(0.2224, 0.205, 0.1882, 0.0902),
  Rect.fromLTWH(0.3003, 0.2994, 0.1147, 0.0975),
  Rect.fromLTWH(0.4679, 0.3326, 0.15, 0.083),
  Rect.fromLTWH(0.6694, 0.3326, 0.3235, 0.083),
  Rect.fromLTWH(0.4635, 0.4124, 0.0721, 0.0913),
  Rect.fromLTWH(0.6518, 0.455, 0.15, 0.084),
  Rect.fromLTWH(0.5826, 0.456, 0.0765, 0.0467),
  Rect.fromLTWH(0.3018, 0.4456, 0.097, 0.0612),
  Rect.fromLTWH(0.3944, 0.4654, 0.0794, 0.0404),
  Rect.fromLTWH(0.1988, 0.4622, 0.1147, 0.0675),
  Rect.fromLTWH(0.2944, 0.5017, 0.0647, 0.1047),
  Rect.fromLTWH(0.2959, 0.5992, 0.0529, 0.0103),
  Rect.fromLTWH(0.0062, 0.2786, 0.1676, 0.1318),
  Rect.fromLTWH(0.0121, 0.2413, 0.0691, 0.0477),
  Rect.fromLTWH(0.1724, 0.3295, 0.075, 0.0954),
  Rect.fromLTWH(0.0106, 0.4114, 0.1632, 0.0176),
  Rect.fromLTWH(0.0062, 0.428, 0.147, 0.2158),
  Rect.fromLTWH(0.1459, 0.568, 0.1029, 0.0426),
  Rect.fromLTWH(0.1194, 0.6127, 0.0471, 0.168),
  Rect.fromLTWH(0.0062, 0.6417, 0.1264, 0.3506),
  Rect.fromLTWH(0.8532, 0.4124, 0.1427, 0.387),
  Rect.fromLTWH(0.5974, 0.5888, 0.2514, 0.0508),
  Rect.fromLTWH(0.4106, 0.5421, 0.1926, 0.0685),
  Rect.fromLTWH(0.5121, 0.6064, 0.1088, 0.0602),
  Rect.fromLTWH(0.9253, 0.7963, 0.0706, 0.196),
  Rect.fromLTWH(0.7165, 0.6718, 0.0853, 0.1784),
  Rect.fromLTWH(0.6782, 0.6759, 0.0427, 0.0955),
  Rect.fromLTWH(0.2209, 0.6448, 0.2426, 0.0944),
  Rect.fromLTWH(0.4738, 0.7112, 0.2162, 0.0602),
  Rect.fromLTWH(0.4724, 0.732, 0.0941, 0.0829),
  Rect.fromLTWH(0.8518, 0.8305, 0.0838, 0.1577),
  Rect.fromLTWH(0.1326, 0.7807, 0.2839, 0.2116),
  Rect.fromLTWH(0.4135, 0.8927, 0.4471, 0.1048),
  Rect.fromLTWH(0.6224, 0.8066, 0.0411, 0.111),
  Rect.fromLTWH(0.3974, 0.8647, 0.2279, 0.0436),
];

const List<Rect> _bodilyMazeHoleRects = [
  Rect.fromLTWH(0.465, 0.2081, 0.1015, 0.0456),
  Rect.fromLTWH(0.3032, 0.4021, 0.1044, 0.0425),
  Rect.fromLTWH(0.6635, 0.5411, 0.1074, 0.0446),
  Rect.fromLTWH(0.5165, 0.6666, 0.1029, 0.0405),
  Rect.fromLTWH(0.4753, 0.816, 0.0971, 0.0425),
];

const MazeLevelConfig bodilyMazeLevel1Config = MazeLevelConfig(
  levelId: 52,
  startPoint: Offset(0.1135, 0.26),
  endPoint: Offset(0.9076, 0.816),
  endPointRadius: 0.04,
  wallRects: _bodilyMazeWallRects,
  holeRects: _bodilyMazeHoleRects,
);

const MazeLevelConfig bodilyMazeLevel2Config = MazeLevelConfig(
  levelId: 53,
  startPoint: Offset(0.1135, 0.26),
  endPoint: Offset(0.9076, 0.816),
  endPointRadius: 0.04,
  wallRects: _bodilyMazeWallRects,
  holeRects: _bodilyMazeHoleRects,
);

const MazeLevelConfig bodilyMazeLevel3Config = MazeLevelConfig(
  levelId: 54,
  startPoint: Offset(0.1135, 0.26),
  endPoint: Offset(0.9076, 0.816),
  endPointRadius: 0.04,
  wallRects: _bodilyMazeWallRects,
  holeRects: _bodilyMazeHoleRects,
);

/// All known level configs.
///
/// حطيت المفاتيح بطريقتين:
/// - 1, 2, 3 حسب levelNumber
/// - 52, 53, 54 حسب backend levelId
///
/// عشان سواء الكود بحث بالـ levelNumber أو بالـ levelId يلاقي config.
const Map<int, MazeLevelConfig> mazeConfigs = {
  1: bodilyMazeLevel1Config,
  2: bodilyMazeLevel2Config,
  3: bodilyMazeLevel3Config,

  52: bodilyMazeLevel1Config,
  53: bodilyMazeLevel2Config,
  54: bodilyMazeLevel3Config,
};