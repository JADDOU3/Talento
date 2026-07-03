import 'package:flutter/material.dart';

/// Per-level maze geometry, defined MANUALLY by the developer — same
/// approach as Bodily Maze's MazeLevelConfig, with two differences:
/// - no holeRects (Cognitive Maze has no fall-through hazards)
/// - a single startPoint but MULTIPLE endPoints, one per answer choice
///
/// endPoints[i] MUST correspond to the same index as the level's
/// choices[i] (from CognitiveMazeLevel.choices) — that pairing is what lets
/// the game know which physical path is the correct answer. Measure and
/// order them to match the backend's choices array exactly.
///
/// All coordinates are NORMALIZED (0.0–1.0) relative to the rendered image
/// size, same convention as Bodily Maze.
class CognitiveMazeLevelConfig {
  /// Backend level id this config belongs to.
  final int levelId;

  /// Ball spawn position (the green dot), normalized 0.0–1.0.
  final Offset startPoint;

  /// One win-zone center per answer choice, normalized 0.0–1.0. Index i
  /// pairs with CognitiveMazeLevel.choices[i].
  final List<Offset> endPoints;

  /// Win zone radius, normalized (relative to image width) — shared by
  /// every endpoint.
  final double endPointRadius;

  /// Wall collision boxes, normalized 0.0–1.0.
  final List<Rect> wallRects;

  const CognitiveMazeLevelConfig({
    required this.levelId,
    required this.startPoint,
    required this.endPoints,
    required this.endPointRadius,
    required this.wallRects,
  });
}

/// All known level configs, keyed by backend levelId.
///
/// ⚠️ DEVELOPER TODO: the key below is 52, carried over as-is from the
/// coordinate-picker draft — the real Level 1 JSON has id 58. Rename the
/// key to 58 (or whichever levelId this geometry was actually measured
/// against) before wiring it up, or CognitiveMazeCubit.loadGame will fail
/// to find a config for the level it loads.
const Map<int, CognitiveMazeLevelConfig> cognitiveMazeConfigs = {
  58: CognitiveMazeLevelConfig(
    levelId: 58,
    startPoint: Offset(0.0656, 0.3733),
    endPoints: [
      Offset(0.6444, 0.2418),
      Offset(0.6522, 0.5378),
      Offset(0.6433, 0.8027),
    ],
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.1689, 0.0951, 0.4078, 0.0693),
      Rect.fromLTWH(0.5022, 0.1476, 0.1945, 0.0808),
      Rect.fromLTWH(0.6644, 0.2098, 0.0389, 0.0684),
      Rect.fromLTWH(0.3856, 0.2613, 0.39, 0.0551),
      Rect.fromLTWH(0.2844, 0.1956, 0.1789, 0.0506),
      Rect.fromLTWH(0.3911, 0.224, 0.0722, 0.0613),
      Rect.fromLTWH(0.3744, 0.232, 0.0445, 0.0187),
      Rect.fromLTWH(0.3878, 0.2462, 0.0222, 0.0196),
      Rect.fromLTWH(0.2822, 0.2809, 0.0645, 0.104),
      Rect.fromLTWH(0.2511, 0.352, 0.2011, 0.0329),
      Rect.fromLTWH(0.2222, 0.3218, 0.0589, 0.1458),
      Rect.fromLTWH(0.3278, 0.4213, 0.1811, 0.1014),
      Rect.fromLTWH(0.5, 0.3538, 0.0989, 0.08),
      Rect.fromLTWH(0.2222, 0.5067, 0.1889, 0.0515),
      Rect.fromLTWH(0.1733, 0.5404, 0.0823, 0.0996),
      Rect.fromLTWH(0.1689, 0.1618, 0.07, 0.128),
      Rect.fromLTWH(0.0156, 0.2871, 0.1633, 0.0702),
      Rect.fromLTWH(0.01, 0.3431, 0.0289, 0.0809),
      Rect.fromLTWH(0.0156, 0.3947, 0.1611, 0.112),
      Rect.fromLTWH(0.1044, 0.4987, 0.0245, 0.1404),
      Rect.fromLTWH(0.0233, 0.6089, 0.1045, 0.0293),
      Rect.fromLTWH(0.0211, 0.6284, 0.0489, 0.1752),
      Rect.fromLTWH(0.0422, 0.7787, 0.1756, 0.0515),
      Rect.fromLTWH(0.1789, 0.832, 0.1033, 0.0933),
      Rect.fromLTWH(0.2822, 0.9129, 0.3211, 0.0293),
      Rect.fromLTWH(0.57, 0.872, 0.0367, 0.0702),
      Rect.fromLTWH(0.3233, 0.8347, 0.2989, 0.0471),
      Rect.fromLTWH(0.3678, 0.736, 0.1522, 0.1218),
      Rect.fromLTWH(0.5144, 0.8231, 0.1667, 0.0293),
      Rect.fromLTWH(0.6611, 0.7822, 0.0311, 0.0747),
      Rect.fromLTWH(0.5633, 0.7022, 0.1289, 0.0898),
      Rect.fromLTWH(0.4556, 0.5582, 0.2444, 0.1458),
      Rect.fromLTWH(0.6722, 0.4996, 0.0467, 0.0906),
      Rect.fromLTWH(0.5533, 0.4658, 0.15, 0.056),
      Rect.fromLTWH(0.6422, 0.3058, 0.0634, 0.1742),
      Rect.fromLTWH(0.3011, 0.5956, 0.1089, 0.1066),
      Rect.fromLTWH(0.1133, 0.6738, 0.2123, 0.0675),
      Rect.fromLTWH(0.2578, 0.7262, 0.0655, 0.0702),
    ],
  ),
};