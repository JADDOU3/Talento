import 'package:flutter/material.dart';

/// Per-level maze geometry, defined MANUALLY by the developer.
///
/// The backend only provides the maze IMAGE — it has no coordinate data for
/// walls, holes, start, or end. The developer overlays coordinates on each
/// level image and fills them in here, keyed by the level's backend id.
///
/// ALL coordinates are NORMALIZED (0.0–1.0) relative to the rendered image
/// size, so they scale correctly across screen sizes. At runtime each value
/// is multiplied by the actual rendered width/height to get pixel positions.
class MazeLevelConfig {
  /// Backend level id this config belongs to.
  final int levelId;

  /// Ball spawn position (the green dot), normalized 0.0–1.0.
  final Offset startPoint;

  /// Win zone center (the red dot), normalized 0.0–1.0.
  final Offset endPoint;

  /// Win zone radius, normalized (relative to image width).
  final double endPointRadius;

  /// Wall collision boxes, normalized 0.0–1.0.
  final List<Rect> wallRects;

  /// Hole zones (the brown gaps), normalized 0.0–1.0.
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

/// All known level configs, keyed by backend levelId.
///
/// ⚠️ DEVELOPER TODO: measure the real coordinates for each level image and
/// fill these in. The values below are PLACEHOLDERS showing the structure —
/// they are NOT measured from the actual images yet. Until a level's real
/// coordinates are added here, that level can't be played correctly.
///
/// How to measure: open the level image, treat top-left as (0,0) and
/// bottom-right as (1,1). For each wall/hole, note the rectangle's left, top,
/// width, height as fractions of the image. For start/end, note the dot's
/// center as a fraction.
const Map<int, MazeLevelConfig> mazeConfigs = {
  // ── Example / placeholder — replace with measured values per real levelId ──
  52: MazeLevelConfig(
    levelId: 52,
    startPoint: Offset(0.1135, 0.26),
    endPoint: Offset(0.9076, 0.816),
    endPointRadius: 0.04,
    wallRects: [
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
    ],
    holeRects: [
      Rect.fromLTWH(0.465, 0.2081, 0.1015, 0.0456),
      Rect.fromLTWH(0.3032, 0.4021, 0.1044, 0.0425),
      Rect.fromLTWH(0.6635, 0.5411, 0.1074, 0.0446),
      Rect.fromLTWH(0.5165, 0.6666, 0.1029, 0.0405),
      Rect.fromLTWH(0.4753, 0.816, 0.0971, 0.0425),
    ],
  ),
  53: MazeLevelConfig(
    levelId: 53,
    startPoint: Offset(0.1032, 0.2543),
    endPoint: Offset(0.9238, 0.7771),
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.0106, 0.0027, 0.9765, 0.158),
      Rect.fromLTWH(0.0091, 0.1617, 0.1383, 0.0728),
      Rect.fromLTWH(0.0106, 0.2709, 0.1382, 0.1372),
      Rect.fromLTWH(0.0179, 0.4091, 0.2706, 0.0385),
      Rect.fromLTWH(0.0121, 0.4507, 0.1, 0.3295),
      Rect.fromLTWH(0.0106, 0.7834, 0.1, 0.2079),
      Rect.fromLTWH(0.1135, 0.8717, 0.2941, 0.1216),
      Rect.fromLTWH(0.4076, 0.88, 0.5809, 0.1133),
      Rect.fromLTWH(0.8871, 0.7948, 0.1058, 0.0956),
      Rect.fromLTWH(0.5797, 0.8717, 0.3074, 0.0395),
      Rect.fromLTWH(0.6724, 0.8021, 0.1691, 0.0353),
      Rect.fromLTWH(0.6018, 0.8, 0.0661, 0.0249),
      Rect.fromLTWH(0.5841, 0.827, 0.0441, 0.051),
      Rect.fromLTWH(0.5856, 0.8021, 0.0206, 0.0291),
      Rect.fromLTWH(0.8871, 0.5609, 0.1, 0.1965),
      Rect.fromLTWH(0.6782, 0.5162, 0.3059, 0.0406),
      Rect.fromLTWH(0.8709, 0.1617, 0.122, 0.3535),
      Rect.fromLTWH(0.7076, 0.195, 0.1177, 0.1092),
      Rect.fromLTWH(0.1974, 0.195, 0.2514, 0.0426),
      Rect.fromLTWH(0.1988, 0.2387, 0.0441, 0.1382),
      Rect.fromLTWH(0.2474, 0.3405, 0.1397, 0.0343),
      Rect.fromLTWH(0.29, 0.2709, 0.0471, 0.079),
      Rect.fromLTWH(0.3253, 0.3281, 0.0147, 0.0166),
      Rect.fromLTWH(0.3385, 0.3353, 0.0412, 0.0104),
      Rect.fromLTWH(0.6121, 0.195, 0.0911, 0.026),
      Rect.fromLTWH(0.6106, 0.221, 0.05, 0.0821),
      Rect.fromLTWH(0.4165, 0.2532, 0.1897, 0.051),
      Rect.fromLTWH(0.4988, 0.1617, 0.0633, 0.0468),
      Rect.fromLTWH(0.3871, 0.2366, 0.0603, 0.0676),
      Rect.fromLTWH(0.4209, 0.3021, 0.0956, 0.0135),
      Rect.fromLTWH(0.4312, 0.3655, 0.0823, 0.0468),
      Rect.fromLTWH(0.5562, 0.3385, 0.1867, 0.0384),
      Rect.fromLTWH(0.6635, 0.378, 0.0794, 0.0426),
      Rect.fromLTWH(0.5547, 0.378, 0.0632, 0.1694),
      Rect.fromLTWH(0.6165, 0.4518, 0.2088, 0.0312),
      Rect.fromLTWH(0.7871, 0.3052, 0.0426, 0.1455),
      Rect.fromLTWH(0.4356, 0.5141, 0.1162, 0.0343),
      Rect.fromLTWH(0.3385, 0.3738, 0.0456, 0.1435),
      Rect.fromLTWH(0.4709, 0.4133, 0.0397, 0.0697),
      Rect.fromLTWH(0.3841, 0.4445, 0.0897, 0.0385),
      Rect.fromLTWH(0.0135, 0.2356, 0.0677, 0.0343),
      Rect.fromLTWH(0.3415, 0.5193, 0.0485, 0.1289),
      Rect.fromLTWH(0.1576, 0.4819, 0.1898, 0.0354),
      Rect.fromLTWH(0.1591, 0.5193, 0.0456, 0.1747),
      Rect.fromLTWH(0.2091, 0.6555, 0.0897, 0.0374),
      Rect.fromLTWH(0.2474, 0.5516, 0.0455, 0.1185),
      Rect.fromLTWH(0.2812, 0.6857, 0.1147, 0.0499),
      Rect.fromLTWH(0.1591, 0.8042, 0.1427, 0.0332),
      Rect.fromLTWH(0.2385, 0.7262, 0.0618, 0.079),
      Rect.fromLTWH(0.1106, 0.7272, 0.0794, 0.0416),
      Rect.fromLTWH(0.1871, 0.7314, 0.0058, 0.0333),
      Rect.fromLTWH(0.3459, 0.7688, 0.1941, 0.0603),
      Rect.fromLTWH(0.4503, 0.8249, 0.0897, 0.0115),
      Rect.fromLTWH(0.39, 0.59, 0.0603, 0.0593),
      Rect.fromLTWH(0.4488, 0.5879, 0.103, 0.0406),
      Rect.fromLTWH(0.4929, 0.6316, 0.0574, 0.0696),
      Rect.fromLTWH(0.4459, 0.6836, 0.05, 0.0852),
      Rect.fromLTWH(0.4885, 0.7335, 0.1706, 0.0343),
      Rect.fromLTWH(0.5929, 0.6753, 0.0677, 0.0582),
      Rect.fromLTWH(0.7047, 0.6773, 0.0456, 0.0811),
      Rect.fromLTWH(0.7444, 0.7012, 0.1, 0.0562),
      Rect.fromLTWH(0.7988, 0.589, 0.0456, 0.1133),
      Rect.fromLTWH(0.5959, 0.6015, 0.2015, 0.0395),
      Rect.fromLTWH(0.5944, 0.5474, 0.0368, 0.0728),
      Rect.fromLTWH(0.6106, 0.4819, 0.0206, 0.0811),
      Rect.fromLTWH(0.5003, 0.7023, 0.0162, 0.0457),
      Rect.fromLTWH(0.5062, 0.7231, 0.0147, 0.026),
      Rect.fromLTWH(0.4944, 0.6981, 0.0338, 0.0083),
      Rect.fromLTWH(0.9415, 0.7563, 0.0456, 0.0395),
    ],
    holeRects: [
      Rect.fromLTWH(0.4988, 0.2085, 0.0662, 0.0447),
      Rect.fromLTWH(0.4282, 0.3187, 0.0839, 0.0447),
      Rect.fromLTWH(0.4371, 0.5536, 0.0794, 0.0333),
      Rect.fromLTWH(0.1179, 0.5505, 0.0339, 0.0551),
      Rect.fromLTWH(0.4562, 0.8395, 0.0838, 0.0395),
      Rect.fromLTWH(0.8312, 0.3437, 0.0382, 0.0582),
      Rect.fromLTWH(0.6797, 0.563, 0.0721, 0.0374),
    ],
  ),
  54: MazeLevelConfig(
    levelId: 54,
    startPoint: Offset(0.0915, 0.2532),
    endPoint: Offset(0.9135, 0.7792),
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.0135, 0.0058, 0.9839, 0.1404),
      Rect.fromLTWH(0.3224, 0.1472, 0.0441, 0.052),
      Rect.fromLTWH(0.8385, 0.1462, 0.1574, 0.1673),
      Rect.fromLTWH(0.8812, 0.3114, 0.1132, 0.2079),
      Rect.fromLTWH(0.7724, 0.5204, 0.222, 0.0343),
      Rect.fromLTWH(0.8591, 0.5557, 0.1368, 0.2048),
      Rect.fromLTWH(0.9282, 0.7615, 0.0647, 0.2246),
      Rect.fromLTWH(0.8606, 0.7969, 0.0838, 0.185),
      Rect.fromLTWH(0.0076, 0.8915, 0.85, 0.1029),
      Rect.fromLTWH(0.0135, 0.8842, 0.1853, 0.0177),
      Rect.fromLTWH(0.0062, 0.5921, 0.1029, 0.289),
      Rect.fromLTWH(0.0032, 0.1462, 0.1486, 0.0914),
      Rect.fromLTWH(0.0047, 0.2407, 0.0618, 0.1591),
      Rect.fromLTWH(0.0047, 0.4008, 0.0735, 0.2048),
      Rect.fromLTWH(0.065, 0.2709, 0.0838, 0.1622),
      Rect.fromLTWH(0.0518, 0.4351, 0.0441, 0.1643),
      Rect.fromLTWH(0.0724, 0.5692, 0.1, 0.0208),
      Rect.fromLTWH(0.0488, 0.563, 0.1221, 0.027),
      Rect.fromLTWH(0.4606, 0.1451, 0.0618, 0.0094),
      Rect.fromLTWH(0.3429, 0.1358, 0.1177, 0.0166),
      Rect.fromLTWH(0.3282, 0.2324, 0.0412, 0.0749),
      Rect.fromLTWH(0.1915, 0.2283, 0.1353, 0.0291),
      Rect.fromLTWH(0.1944, 0.1784, 0.0794, 0.0717),
      Rect.fromLTWH(0.1944, 0.2584, 0.0309, 0.2058),
      Rect.fromLTWH(0.2194, 0.4133, 0.2632, 0.0239),
      Rect.fromLTWH(0.4444, 0.4393, 0.0412, 0.0488),
      Rect.fromLTWH(0.7576, 0.1784, 0.0412, 0.133),
      Rect.fromLTWH(0.5576, 0.1784, 0.203, 0.0218),
      Rect.fromLTWH(0.5591, 0.2012, 0.0368, 0.1279),
      Rect.fromLTWH(0.4871, 0.2771, 0.0735, 0.052),
      Rect.fromLTWH(0.5988, 0.3021, 0.0456, 0.0353),
      Rect.fromLTWH(0.6341, 0.2314, 0.0824, 0.0385),
      Rect.fromLTWH(0.6871, 0.2719, 0.0323, 0.0967),
      Rect.fromLTWH(0.7135, 0.3437, 0.1265, 0.028),
      Rect.fromLTWH(0.8047, 0.3728, 0.0368, 0.1185),
      Rect.fromLTWH(0.6724, 0.4601, 0.1308, 0.0312),
      Rect.fromLTWH(0.2679, 0.2854, 0.0192, 0.1009),
      Rect.fromLTWH(0.2841, 0.352, 0.1618, 0.0343),
      Rect.fromLTWH(0.4106, 0.2397, 0.0338, 0.1123),
      Rect.fromLTWH(0.44, 0.1992, 0.0765, 0.0478),
      Rect.fromLTWH(0.4106, 0.1794, 0.022, 0.0749),
      Rect.fromLTWH(0.4341, 0.2449, 0.0206, 0.0094),
      Rect.fromLTWH(0.4356, 0.3613, 0.1206, 0.025),
      Rect.fromLTWH(0.5268, 0.3894, 0.0294, 0.1632),
      Rect.fromLTWH(0.5224, 0.3842, 0.0088, 0.0572),
      Rect.fromLTWH(0.5224, 0.4861, 0.0073, 0.0696),
      Rect.fromLTWH(0.1341, 0.4653, 0.0883, 0.0655),
      Rect.fromLTWH(0.2165, 0.5339, 0.0735, 0.0561),
      Rect.fromLTWH(0.1532, 0.6316, 0.1015, 0.0541),
      Rect.fromLTWH(0.1532, 0.6243, 0.0324, 0.2298),
      Rect.fromLTWH(0.1768, 0.8052, 0.1117, 0.0468),
      Rect.fromLTWH(0.1738, 0.6836, 0.0162, 0.1247),
      Rect.fromLTWH(0.2988, 0.5859, 0.1368, 0.0353),
      Rect.fromLTWH(0.2988, 0.6233, 0.0368, 0.1403),
      Rect.fromLTWH(0.2341, 0.7127, 0.0677, 0.0624),
      Rect.fromLTWH(0.3341, 0.7335, 0.0956, 0.0291),
      Rect.fromLTWH(0.3974, 0.7626, 0.0338, 0.0447),
      Rect.fromLTWH(0.3312, 0.7948, 0.0309, 0.0665),
      Rect.fromLTWH(0.3562, 0.8374, 0.3882, 0.0239),
      Rect.fromLTWH(0.4665, 0.7158, 0.0426, 0.1195),
      Rect.fromLTWH(0.4974, 0.7148, 0.1308, 0.027),
      Rect.fromLTWH(0.5988, 0.379, 0.028, 0.3347),
      Rect.fromLTWH(0.5576, 0.5827, 0.0721, 0.0364),
      Rect.fromLTWH(0.6165, 0.5328, 0.1147, 0.0344),
      Rect.fromLTWH(0.6224, 0.562, 0.0102, 0.0249),
      Rect.fromLTWH(0.6165, 0.404, 0.1456, 0.0259),
      Rect.fromLTWH(0.6194, 0.3811, 0.025, 0.028),
      Rect.fromLTWH(0.6209, 0.432, 0.0132, 0.1029),
      Rect.fromLTWH(0.6738, 0.5983, 0.1471, 0.0271),
      Rect.fromLTWH(0.7841, 0.6274, 0.0397, 0.0967),
      Rect.fromLTWH(0.6724, 0.6285, 0.0338, 0.2068),
      Rect.fromLTWH(0.7474, 0.6576, 0.0338, 0.1434),
      Rect.fromLTWH(0.7841, 0.7647, 0.0338, 0.0956),
      Rect.fromLTWH(0.7003, 0.8312, 0.0382, 0.0093),
      Rect.fromLTWH(0.5915, 0.8229, 0.0809, 0.0208),
      Rect.fromLTWH(0.49, 0.8301, 0.1059, 0.0125),
      Rect.fromLTWH(0.59, 0.7751, 0.0412, 0.0478),
      Rect.fromLTWH(0.5459, 0.774, 0.0559, 0.027),
      Rect.fromLTWH(0.3753, 0.6482, 0.1809, 0.0364),
      Rect.fromLTWH(0.3753, 0.6742, 0.0544, 0.0198),
      Rect.fromLTWH(0.4753, 0.5193, 0.0441, 0.1279),
      Rect.fromLTWH(0.3312, 0.5193, 0.1441, 0.0333),
      Rect.fromLTWH(0.3341, 0.4705, 0.0735, 0.0488),
      Rect.fromLTWH(0.2665, 0.4694, 0.072, 0.0208),
      Rect.fromLTWH(0.265, 0.4902, 0.0265, 0.0104),
      Rect.fromLTWH(0.2209, 0.5214, 0.0088, 0.0291),
      Rect.fromLTWH(0.2135, 0.5214, 0.0118, 0.026),
      Rect.fromLTWH(0.2018, 0.5266, 0.0176, 0.0073),
      Rect.fromLTWH(0.2812, 0.5786, 0.0206, 0.0104),
    ],
    holeRects: [
      Rect.fromLTWH(0.7988, 0.2137, 0.0383, 0.0489),
      Rect.fromLTWH(0.4606, 0.1586, 0.0588, 0.0364),
      Rect.fromLTWH(0.5974, 0.3405, 0.047, 0.0385),
      Rect.fromLTWH(0.3224, 0.3094, 0.0485, 0.0426),
      Rect.fromLTWH(0.1518, 0.3208, 0.0353, 0.0488),
      Rect.fromLTWH(0.49, 0.4424, 0.0353, 0.0385),
      Rect.fromLTWH(0.6753, 0.4944, 0.0559, 0.0343),
      Rect.fromLTWH(0.7694, 0.5578, 0.05, 0.0364),
      Rect.fromLTWH(0.6326, 0.6857, 0.0368, 0.0436),
      Rect.fromLTWH(0.6047, 0.8644, 0.0529, 0.026),
      Rect.fromLTWH(0.2297, 0.8593, 0.0603, 0.0311),
      Rect.fromLTWH(0.3724, 0.6971, 0.0544, 0.0322),
      Rect.fromLTWH(0.2121, 0.5942, 0.047, 0.0374),
    ],
  ),
};

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