import 'package:flutter/material.dart';


class PalestineFlagColors {
  static const red = Color(0xFFCE1126);
  static const green = Color(0xFF007A3D);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  static final Set<Color> all = {red, green, black, white};
}

class MazeStar {
  final Offset position; // normalized 0.0–1.0
  final Color color;
  final double radius; // normalized, relative to image width

  const MazeStar({
    required this.position,
    required this.color,
    this.radius = 0.035,
  });
}

class CognitiveMazeLevelConfig {
  final int levelId;
  final Offset startPoint;

  /// Single-answer mode (level 1 style). Empty for star-collect levels.
  final List<Offset> endPoints;
  final double endPointRadius;

  final List<Rect> wallRects;

  /// Star-collect mode (level 2 style). Empty for single-answer levels.
  final List<MazeStar> stars;

  /// Colors that must ALL be collected to finish a star-collect level.
  final Set<Color> targetColors;

  const CognitiveMazeLevelConfig({
    required this.levelId,
    required this.startPoint,
    this.endPoints = const [],
    this.endPointRadius = 0.04,
    required this.wallRects,
    this.stars = const [],
    this.targetColors = const {},
  });

  bool get isStarCollectLevel => stars.isNotEmpty;
}

final  Map<int, CognitiveMazeLevelConfig> cognitiveMazeConfigs = {
  58: CognitiveMazeLevelConfig(
    levelId: 58,
    startPoint: Offset(0.0656, 0.3733),
    endPoints: [
      Offset(0.6433, 0.8027),
      Offset(0.6444, 0.2418),
      Offset(0.6522, 0.5378),
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
  59: CognitiveMazeLevelConfig(
    levelId: 59,
    startPoint: Offset(0.0878, 0.2652),
    endPoints: [Offset(0.8533, 0.7984)],
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.2067, 0.1526, 0.2355, 0.0169),
      Rect.fromLTWH(0.4189, 0.167, 0.0722, 0.095),
      Rect.fromLTWH(0.5167, 0.2489, 0.08, 0.1082),
      Rect.fromLTWH(0.4844, 0.2477, 0.06, 0.0162),
      Rect.fromLTWH(0.5567, 0.331, 0.32, 0.0244),
      Rect.fromLTWH(0.7533, 0.2629, 0.1223, 0.09),
      Rect.fromLTWH(0.6489, 0.3504, 0.0867, 0.1145),
      Rect.fromLTWH(0.6511, 0.4605, 0.1533, 0.0657),
      Rect.fromLTWH(0.5156, 0.4674, 0.1611, 0.06),
      Rect.fromLTWH(0.3822, 0.5149, 0.1778, 0.0275),
      Rect.fromLTWH(0.4511, 0.5287, 0.1089, 0.0719),
      Rect.fromLTWH(0.1567, 0.3554, 0.1855, 0.0957),
      Rect.fromLTWH(0.2989, 0.4424, 0.16, 0.0412),
      Rect.fromLTWH(0.2667, 0.5733, 0.13, 0.0413),
      Rect.fromLTWH(0.26, 0.4532, 0.07, 0.1226),
      Rect.fromLTWH(0.2544, 0.4469, 0.0656, 0.1114),
      Rect.fromLTWH(0.26, 0.5533, 0.0711, 0.0613),
      Rect.fromLTWH(0.2678, 0.6064, 0.1233, 0.015),
      Rect.fromLTWH(0.3689, 0.6239, 0.0278, 0.1351),
      Rect.fromLTWH(0.3622, 0.6058, 0.0078, 0.1663),
      Rect.fromLTWH(0.3833, 0.6296, 0.1778, 0.035),
      Rect.fromLTWH(0.3967, 0.66, 0.0311, 0.1282),
      Rect.fromLTWH(0.3978, 0.7638, 0.1266, 0.02),
      Rect.fromLTWH(0.4489, 0.7713, 0.0722, 0.0688),
      Rect.fromLTWH(0.5167, 0.8226, 0.4, 0.0325),
      Rect.fromLTWH(0.8911, 0.5956, 0.08, 0.2501),
      Rect.fromLTWH(0.6156, 0.5595, 0.36, 0.0394),
      Rect.fromLTWH(0.6156, 0.5922, 0.1188, 0.0676),
      Rect.fromLTWH(0.6811, 0.6548, 0.0533, 0.0531),
      Rect.fromLTWH(0.4711, 0.6948, 0.16, 0.0394),
      Rect.fromLTWH(0.5744, 0.74, 0.2145, 0.0513),
      Rect.fromLTWH(0.7844, 0.6275, 0.0567, 0.1188),
      Rect.fromLTWH(0.7744, 0.725, 0.0345, 0.0157),
      Rect.fromLTWH(0.7778, 0.7375, 0.0278, 0.0176),
      Rect.fromLTWH(0.5744, 0.7282, 0.0534, 0.0344),
      Rect.fromLTWH(0.8578, 0.428, 0.09, 0.1501),
      Rect.fromLTWH(0.7878, 0.3898, 0.1589, 0.0407),
      Rect.fromLTWH(0.9267, 0.226, 0.0555, 0.1726),
      Rect.fromLTWH(0.8333, 0.162, 0.11, 0.0656),
      Rect.fromLTWH(0.5433, 0.1914, 0.2267, 0.0281),
      Rect.fromLTWH(0.7178, 0.1945, 0.0622, 0.0331),
      Rect.fromLTWH(0.65, 0.2026, 0.0533, 0.0938),
      Rect.fromLTWH(0.4811, 0.1463, 0.4456, 0.0176),
      Rect.fromLTWH(0.2667, 0.2005, 0.1033, 0.1226),
      Rect.fromLTWH(0.3378, 0.2944, 0.1355, 0.0293),
      Rect.fromLTWH(0.3889, 0.2994, 0.0789, 0.1063),
      Rect.fromLTWH(0.5089, 0.3894, 0.0889, 0.0469),
      Rect.fromLTWH(0.4356, 0.3888, 0.12, 0.0181),
      Rect.fromLTWH(0.0578, 0.2843, 0.1533, 0.0401),
      Rect.fromLTWH(0.2044, 0.1611, 0.0056, 0.0932),
      Rect.fromLTWH(0.0233, 0.2293, 0.1878, 0.0238),
      Rect.fromLTWH(0.0278, 0.2387, 0.0344, 0.085),
      Rect.fromLTWH(0.1244, 0.158, 0.0889, 0.0963),
      Rect.fromLTWH(0.0289, 0.3179, 0.0789, 0.2158),
      Rect.fromLTWH(0.0944, 0.4805, 0.1067, 0.0607),
      Rect.fromLTWH(0.0578, 0.5391, 0.0711, 0.1907),
      Rect.fromLTWH(0.0722, 0.704, 0.1434, 0.0656),
      Rect.fromLTWH(0.1533, 0.7534, 0.2211, 0.0275),
      Rect.fromLTWH(0.1733, 0.5729, 0.0456, 0.1013),
      Rect.fromLTWH(0.1789, 0.6504, 0.1333, 0.0225),
      Rect.fromLTWH(0.2633, 0.6579, 0.0534, 0.0688),
    ],
    stars: [
      MazeStar(position: Offset(0.6722, 0.3139), color: PalestineFlagColors.red),
      MazeStar(position: Offset(0.7656, 0.4028), color: PalestineFlagColors.green),
      MazeStar(position: Offset(0.4556, 0.7121), color: PalestineFlagColors.black),
      MazeStar(position: Offset(0.7089, 0.7221), color: PalestineFlagColors.white),
      MazeStar(position: Offset(0.3522, 0.6865), color: Colors.blue),
      MazeStar(position: Offset(0.1578, 0.6421), color: Colors.orange),
      MazeStar(position: Offset(0.4667, 0.424), color: Colors.purple),
      MazeStar(position: Offset(0.5067, 0.6146), color: Colors.yellow),
    ],
    targetColors: PalestineFlagColors.all,
  ),
};