import 'package:flutter/material.dart';

/// Per-level maze geometry. The backend only provides the map image and
/// question data — the developer manually defines walls, holes, star
/// positions, and the end-block zone here, keyed by the backend levelId.
///
/// ALL coordinates are NORMALIZED (0.0–1.0), same convention as Bodily Maze.
/// starPositions maps challengeId → normalized position on the image; the
/// challengeId comes from the backend's meta.
class AdventureMazeLevelConfig {
  final int levelId;

  /// Ball spawn position (green dot), normalized 0.0–1.0.
  final Offset startPoint;

  /// Win zone center (red/blue dot), normalized 0.0–1.0.
  final Offset endPoint;

  /// Win zone radius, normalized (relative to image width).
  final double endPointRadius;

  /// Wall collision boxes, normalized 0.0–1.0.
  final List<Rect> wallRects;

  /// Hole (jump) zones — brown gaps.
  final List<Rect> holeRects;

  /// challengeId → position of that star on the image, normalized 0.0–1.0.
  final Map<int, Offset> starPositions;

  /// challengeId → color for that star. Set this per-level, per-star,
  /// same as MazeStar.color in Cognitive Maze. Falls back to gold if a
  /// challengeId is missing from this map.
  final Map<int, Color> starColors;

  /// Zone that blocks the path to the end point until every star is
  /// collected. Uses the same collision logic as a wall; simply removed once
  /// all challenges are answered.
  final Rect endBlockRect;

  const AdventureMazeLevelConfig({
    required this.levelId,
    required this.startPoint,
    required this.endPoint,
    required this.endPointRadius,
    required this.wallRects,
    required this.holeRects,
    required this.starPositions,
    this.starColors = const {},
    required this.endBlockRect,
  });
}

/// All known Adventure Maze level configs, keyed by backend levelId.
///
/// ⚠️ DEVELOPER TODO: measure real coordinates for each level image and
/// fill these in. The values below are PLACEHOLDERS. Use the maze
/// coordinate picker tool to measure them.
const Map<int, AdventureMazeLevelConfig> adventureMazeConfigs = {
  // Example placeholder — replace with measured values per real levelId.
  63: AdventureMazeLevelConfig(
    levelId: 63,
    startPoint: Offset(0.0578, 0.3436),
    endPoint: Offset(0.9511, 0.7228),
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.0156, 0.0087, 0.9755, 0.106),
      Rect.fromLTWH(0.8756, 0.1154, 0.11, 0.3126),
      Rect.fromLTWH(0.8767, 0.428, 0.1133, 0.0385),
      Rect.fromLTWH(0.8833, 0.4665, 0.1034, 0.243),
      Rect.fromLTWH(0.8867, 0.7391, 0.1044, 0.2556),
      Rect.fromLTWH(0.0089, 0.8754, 0.88, 0.1193),
      Rect.fromLTWH(0.0022, 0.3599, 0.1078, 0.5148),
      Rect.fromLTWH(0.0111, 0.1169, 0.1, 0.2126),
      Rect.fromLTWH(0.0044, 0.3302, 0.0267, 0.0385),
      Rect.fromLTWH(0.11, 0.5613, 0.07, 0.0356),
      Rect.fromLTWH(0.1078, 0.1154, 0.1544, 0.0207),
      Rect.fromLTWH(0.4922, 0.1169, 0.0322, 0.0541),
      Rect.fromLTWH(0.2322, 0.1361, 0.0289, 0.0349),
      Rect.fromLTWH(0.5656, 0.1458, 0.2666, 0.0296),
      Rect.fromLTWH(0.7222, 0.1761, 0.0311, 0.0467),
      Rect.fromLTWH(0.8133, 0.1761, 0.0223, 0.0371),
      Rect.fromLTWH(0.79, 0.2147, 0.0444, 0.0652),
      Rect.fromLTWH(0.7922, 0.2065, 0.0278, 0.0134),
      Rect.fromLTWH(0.7456, 0.1695, 0.07, 0.0096),
      Rect.fromLTWH(0.6389, 0.2495, 0.15, 0.0296),
      Rect.fromLTWH(0.6389, 0.2036, 0.0433, 0.057),
      Rect.fromLTWH(0.6767, 0.2043, 0.0077, 0.0489),
      Rect.fromLTWH(0.5744, 0.2621, 0.0678, 0.0666),
      Rect.fromLTWH(0.6267, 0.2806, 0.0322, 0.0993),
      Rect.fromLTWH(0.3644, 0.3036, 0.21, 0.0237),
      Rect.fromLTWH(0.4911, 0.3273, 0.0333, 0.1059),
      Rect.fromLTWH(0.2967, 0.4073, 0.1966, 0.0281),
      Rect.fromLTWH(0.4556, 0.4361, 0.0277, 0.0541),
      Rect.fromLTWH(0.6378, 0.7584, 0.0744, 0.0237),
      Rect.fromLTWH(0.6756, 0.7206, 0.17, 0.04),
      Rect.fromLTWH(0.7111, 0.751, 0.0089, 0.017),
      Rect.fromLTWH(0.6722, 0.751, 0.0111, 0.0089),
      Rect.fromLTWH(0.6756, 0.6295, 0.0422, 0.0911),
      Rect.fromLTWH(0.7511, 0.791, 0.0933, 0.0555),
      Rect.fromLTWH(0.5478, 0.8161, 0.2044, 0.0312),
      Rect.fromLTWH(0.3878, 0.8184, 0.1211, 0.0548),
      Rect.fromLTWH(0.1489, 0.8302, 0.2333, 0.0171),
      Rect.fromLTWH(0.1489, 0.7984, 0.0355, 0.034),
      Rect.fromLTWH(0.3367, 0.7739, 0.0533, 0.0748),
      Rect.fromLTWH(0.3311, 0.8243, 0.0089, 0.0089),
      Rect.fromLTWH(0.3856, 0.8095, 0.0122, 0.0126),
      Rect.fromLTWH(0.2222, 0.7732, 0.1156, 0.0318),
      Rect.fromLTWH(0.2111, 0.7391, 0.0511, 0.0341),
      Rect.fromLTWH(0.1489, 0.7391, 0.0922, 0.0304),
      Rect.fromLTWH(0.1489, 0.6243, 0.04, 0.1148),
      Rect.fromLTWH(0.1678, 0.6228, 0.0978, 0.0252),
      Rect.fromLTWH(0.1889, 0.6473, 0.0078, 0.0044),
      Rect.fromLTWH(0.22, 0.5013, 0.0467, 0.1215),
      Rect.fromLTWH(0.2156, 0.6169, 0.0088, 0.0074),
      Rect.fromLTWH(0.2633, 0.5406, 0.2223, 0.0222),
      Rect.fromLTWH(0.2633, 0.5584, 0.0123, 0.0089),
      Rect.fromLTWH(0.2622, 0.5369, 0.0089, 0.0081),
      Rect.fromLTWH(0.4511, 0.5221, 0.0356, 0.1029),
      Rect.fromLTWH(0.4544, 0.6228, 0.0278, 0.0037),
      Rect.fromLTWH(0.44, 0.5584, 0.01, 0.0074),
      Rect.fromLTWH(0.3878, 0.5243, 0.0689, 0.0193),
      Rect.fromLTWH(0.3822, 0.5369, 0.0089, 0.0074),
      Rect.fromLTWH(0.3889, 0.4636, 0.0311, 0.08),
      Rect.fromLTWH(0.4133, 0.5221, 0.0378, 0.0089),
      Rect.fromLTWH(0.4167, 0.5139, 0.0089, 0.0111),
      Rect.fromLTWH(0.4189, 0.4665, 0.0033, 0.0571),
      Rect.fromLTWH(0.5467, 0.7658, 0.0533, 0.0503),
      Rect.fromLTWH(0.5822, 0.6895, 0.0556, 0.0385),
      Rect.fromLTWH(0.5789, 0.7199, 0.0567, 0.0103),
      Rect.fromLTWH(0.5789, 0.7302, 0.0222, 0.0408),
      Rect.fromLTWH(0.57, 0.7613, 0.0122, 0.0089),
      Rect.fromLTWH(0.6, 0.7287, 0.0067, 0.0067),
      Rect.fromLTWH(0.5989, 0.8132, 0.0089, 0.0074),
      Rect.fromLTWH(0.7467, 0.8124, 0.0044, 0.0082),
      Rect.fromLTWH(0.7156, 0.7154, 0.0088, 0.0052),
      Rect.fromLTWH(0.4322, 0.7658, 0.1145, 0.0237),
      Rect.fromLTWH(0.4322, 0.7139, 0.0389, 0.0608),
      Rect.fromLTWH(0.4678, 0.7636, 0.0133, 0.0066),
      Rect.fromLTWH(0.47, 0.7584, 0.0056, 0.0074),
      Rect.fromLTWH(0.3022, 0.7132, 0.1522, 0.0296),
      Rect.fromLTWH(0.4256, 0.7399, 0.0088, 0.0081),
      Rect.fromLTWH(0.2278, 0.6784, 0.1055, 0.0303),
      Rect.fromLTWH(0.2244, 0.6799, 0.0056, 0.0259),
      Rect.fromLTWH(0.2944, 0.7073, 0.0445, 0.0059),
      Rect.fromLTWH(0.3067, 0.5917, 0.0266, 0.0859),
      Rect.fromLTWH(0.3022, 0.6717, 0.0089, 0.0133),
      Rect.fromLTWH(0.2933, 0.6754, 0.0167, 0.0052),
      Rect.fromLTWH(0.3322, 0.591, 0.08, 0.0459),
      Rect.fromLTWH(0.3289, 0.6347, 0.01, 0.0081),
      Rect.fromLTWH(0.3733, 0.6354, 0.0367, 0.0496),
      Rect.fromLTWH(0.4089, 0.6561, 0.1355, 0.0297),
      Rect.fromLTWH(0.51, 0.6865, 0.0333, 0.0496),
      Rect.fromLTWH(0.5056, 0.6828, 0.01, 0.0082),
      Rect.fromLTWH(0.4067, 0.651, 0.01, 0.0051),
      Rect.fromLTWH(0.5289, 0.6302, 0.1467, 0.0319),
      Rect.fromLTWH(0.6678, 0.6591, 0.0166, 0.0067),
      Rect.fromLTWH(0.5422, 0.6591, 0.0111, 0.0067),
      Rect.fromLTWH(0.5222, 0.6495, 0.0134, 0.0089),
      Rect.fromLTWH(0.5311, 0.5184, 0.0389, 0.1089),
      Rect.fromLTWH(0.5356, 0.6265, 0.0422, 0.0052),
      Rect.fromLTWH(0.5378, 0.5169, 0.1278, 0.0267),
      Rect.fromLTWH(0.5678, 0.5413, 0.0089, 0.0089),
      Rect.fromLTWH(0.5722, 0.5287, 0.0934, 0.0178),
      Rect.fromLTWH(0.6322, 0.4621, 0.0311, 0.0548),
      Rect.fromLTWH(0.6222, 0.5139, 0.0167, 0.006),
      Rect.fromLTWH(0.6622, 0.4613, 0.1378, 0.026),
      Rect.fromLTWH(0.6622, 0.485, 0.0111, 0.0067),
      Rect.fromLTWH(0.7822, 0.4887, 0.0611, 0.0637),
      Rect.fromLTWH(0.7733, 0.4843, 0.0167, 0.0052),
      Rect.fromLTWH(0.7978, 0.485, 0.0122, 0.0052),
      Rect.fromLTWH(0.8267, 0.5524, 0.02, 0.1719),
      Rect.fromLTWH(0.8356, 0.4887, 0.0088, 0.0637),
      Rect.fromLTWH(0.8233, 0.7169, 0.0123, 0.0081),
      Rect.fromLTWH(0.9689, 0.7073, 0.0222, 0.037),
      Rect.fromLTWH(0.76, 0.5821, 0.0311, 0.1118),
      Rect.fromLTWH(0.7578, 0.6028, 0.0111, 0.0711),
      Rect.fromLTWH(0.7056, 0.5169, 0.0388, 0.083),
      Rect.fromLTWH(0.6078, 0.5739, 0.1366, 0.026),
      Rect.fromLTWH(0.7289, 0.5813, 0.0322, 0.0186),
      Rect.fromLTWH(0.6933, 0.5687, 0.0178, 0.0074),
      Rect.fromLTWH(0.7422, 0.5747, 0.0089, 0.0111),
      Rect.fromLTWH(0.7511, 0.5939, 0.0133, 0.0141),
      Rect.fromLTWH(0.7767, 0.3695, 0.0233, 0.0911),
      Rect.fromLTWH(0.7733, 0.4554, 0.0089, 0.0082),
      Rect.fromLTWH(0.7989, 0.3695, 0.0367, 0.0318),
      Rect.fromLTWH(0.79, 0.3932, 0.0411, 0.0096),
      Rect.fromLTWH(0.7967, 0.4013, 0.0077, 0.0074),
      Rect.fromLTWH(0.8078, 0.3073, 0.0278, 0.0614),
      Rect.fromLTWH(0.6978, 0.3073, 0.1366, 0.0318),
      Rect.fromLTWH(0.6967, 0.3391, 0.04, 0.0926),
      Rect.fromLTWH(0.5622, 0.4073, 0.1367, 0.0259),
      Rect.fromLTWH(0.5222, 0.4606, 0.0711, 0.0267),
      Rect.fromLTWH(0.5611, 0.431, 0.0322, 0.037),
      Rect.fromLTWH(0.5589, 0.4539, 0.0089, 0.0111),
      Rect.fromLTWH(0.5622, 0.3584, 0.0267, 0.0481),
      Rect.fromLTWH(0.5856, 0.4043, 0.0111, 0.0059),
      Rect.fromLTWH(0.5933, 0.4317, 0.0089, 0.0074),
      Rect.fromLTWH(0.6933, 0.4028, 0.0078, 0.0074),
      Rect.fromLTWH(0.8044, 0.3361, 0.0045, 0.006),
      Rect.fromLTWH(0.7278, 0.3369, 0.0155, 0.0067),
      Rect.fromLTWH(0.84, 0.428, 0.0378, 0.0326),
      Rect.fromLTWH(0.3033, 0.1443, 0.1467, 0.0378),
      Rect.fromLTWH(0.15, 0.165, 0.04, 0.0571),
      Rect.fromLTWH(0.1833, 0.1984, 0.1523, 0.0222),
      Rect.fromLTWH(0.3022, 0.1791, 0.03, 0.0311),
      Rect.fromLTWH(0.3011, 0.1732, 0.0345, 0.0318),
      Rect.fromLTWH(0.2844, 0.3576, 0.1645, 0.0252),
      Rect.fromLTWH(0.2856, 0.3073, 0.0366, 0.0644),
      Rect.fromLTWH(0.3178, 0.348, 0.0078, 0.0119),
      Rect.fromLTWH(0.32, 0.3095, 0.0044, 0.0437),
      Rect.fromLTWH(0.5644, 0.1761, 0.0356, 0.0563),
      Rect.fromLTWH(0.4222, 0.1836, 0.0289, 0.0496),
      Rect.fromLTWH(0.4478, 0.1984, 0.1166, 0.0326),
      Rect.fromLTWH(0.4789, 0.2302, 0.0589, 0.0378),
      Rect.fromLTWH(0.4711, 0.2199, 0.0078, 0.02),
      Rect.fromLTWH(0.5322, 0.2265, 0.0334, 0.0074),
      Rect.fromLTWH(0.53, 0.2317, 0.0133, 0.0067),
      Rect.fromLTWH(0.45, 0.2295, 0.0256, 0.0059),
      Rect.fromLTWH(0.3744, 0.211, 0.0145, 0.0985),
      Rect.fromLTWH(0.3822, 0.2621, 0.0622, 0.0481),
      Rect.fromLTWH(0.4856, 0.3302, 0.0111, 0.0045),
      Rect.fromLTWH(0.5211, 0.3243, 0.0122, 0.0089),
      Rect.fromLTWH(0.6178, 0.3287, 0.0089, 0.0067),
      Rect.fromLTWH(0.6578, 0.2747, 0.0055, 0.0103),
      Rect.fromLTWH(0.2133, 0.2473, 0.16, 0.0326),
      Rect.fromLTWH(0.3611, 0.2769, 0.0256, 0.0267),
      Rect.fromLTWH(0.3589, 0.2791, 0.0122, 0.0037),
      Rect.fromLTWH(0.3867, 0.2524, 0.0044, 0.0126),
      Rect.fromLTWH(0.1489, 0.2213, 0.0278, 0.1148),
      Rect.fromLTWH(0.1711, 0.308, 0.0745, 0.0296),
      Rect.fromLTWH(0.15, 0.3658, 0.1433, 0.0163),
      Rect.fromLTWH(0.2033, 0.3836, 0.0545, 0.034),
      Rect.fromLTWH(0.2478, 0.3776, 0.0166, 0.0082),
      Rect.fromLTWH(0.3033, 0.4354, 0.0467, 0.0719),
      Rect.fromLTWH(0.2978, 0.4347, 0.0133, 0.0437),
      Rect.fromLTWH(0.1489, 0.4465, 0.15, 0.0274),
      Rect.fromLTWH(0.1489, 0.4739, 0.0344, 0.0563),
      Rect.fromLTWH(0.1478, 0.3791, 0.0178, 0.0659),
      Rect.fromLTWH(0.16, 0.3813, 0.0622, 0.0289),
      Rect.fromLTWH(0.1622, 0.408, 0.0067, 0.0096),
      Rect.fromLTWH(0.1611, 0.4421, 0.0111, 0.0089),
      Rect.fromLTWH(0.1822, 0.4724, 0.0089, 0.0045),
      Rect.fromLTWH(0.1978, 0.4102, 0.01, 0.0052),
      Rect.fromLTWH(0.1644, 0.4073, 0.0089, 0.0066),
      Rect.fromLTWH(0.3467, 0.4324, 0.01, 0.0052),
      Rect.fromLTWH(0.4856, 0.4013, 0.0111, 0.0097),
      Rect.fromLTWH(0.1067, 0.5569, 0.0111, 0.0074),
      Rect.fromLTWH(0.1022, 0.5954, 0.0134, 0.0045),
      Rect.fromLTWH(0.8711, 0.8739, 0.0245, 0.0097),
      Rect.fromLTWH(0.88, 0.8665, 0.0089, 0.0141),
      Rect.fromLTWH(0.8833, 0.7821, 0.0056, 0.0903),
      Rect.fromLTWH(0.6356, 0.2561, 0.0077, 0.0089),
      Rect.fromLTWH(0.6856, 0.2465, 0.0044, 0.0045),
      Rect.fromLTWH(0.7833, 0.2473, 0.0111, 0.0096),
      Rect.fromLTWH(0.8056, 0.2028, 0.0166, 0.0059),
      Rect.fromLTWH(0.56, 0.1939, 0.0078, 0.006),
      Rect.fromLTWH(0.4489, 0.1939, 0.0044, 0.0037),
      Rect.fromLTWH(0.4156, 0.1806, 0.0066, 0.0044),
      Rect.fromLTWH(0.4867, 0.1132, 0.0077, 0.0059),
      Rect.fromLTWH(0.52, 0.1124, 0.0167, 0.0045),
      Rect.fromLTWH(0.2589, 0.1117, 0.0078, 0.0082),
      Rect.fromLTWH(0.2189, 0.1347, 0.0189, 0.0037),
      Rect.fromLTWH(0.1033, 0.1361, 0.0123, 0.006),
      Rect.fromLTWH(0.4467, 0.3613, 0.0066, 0.0215),
      Rect.fromLTWH(0.3222, 0.3539, 0.0134, 0.0067),
      Rect.fromLTWH(0.96, 0.7361, 0.0133, 0.006),
      Rect.fromLTWH(0.3833, 0.871, 0.0056, 0.0059),
      Rect.fromLTWH(0.5078, 0.8687, 0.0078, 0.0067),
      Rect.fromLTWH(0.0956, 0.8695, 0.0222, 0.0066),
    ],
    holeRects: [
      Rect.fromLTWH(0.4767, 0.2687, 0.0611, 0.0349),
      Rect.fromLTWH(0.3022, 0.508, 0.0545, 0.0326),
      Rect.fromLTWH(0.64, 0.7828, 0.0722, 0.0326),
    ],
    starPositions: {
      1: Offset(0.8522, 0.291),
      2: Offset(0.24, 0.4865),
      3: Offset(0.7378, 0.2361),
      4: Offset(0.3889, 0.6984),
      5: Offset(0.7978, 0.8621),
    },
    // Assign each star's color explicitly, same as Cognitive Maze's
    // MazeStar(position: ..., color: ...) — change these to whatever you
    // want per level.
    starColors: {
      1: Color(0xFF29B6F6), // blue
      2: Color(0xFFAB47BC), // purple
      3: Color(0xFFFF7043), // orange
      4: Color(0xFF66BB6A), // green
      5: Color(0xFFFFD600), // gold
    },
    endBlockRect: Rect.fromLTWH(0.8856, 0.7117, 0.0122, 0.0244),
  ),
};