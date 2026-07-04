import 'package:flutter/material.dart';

class MazeLevelConfig {
  final int levelId;
  final Offset startPoint;

  /// All endpoints are valid — reaching any one of them finishes the level.
  final List<Offset> endPoints;
  final double endPointRadius;

  final List<Rect> wallRects;

  /// Reserved for future use (pits/traps). Empty = no hole behavior yet.
  final List<Rect> holeRects;

  const MazeLevelConfig({
    required this.levelId,
    required this.startPoint,
    required this.endPoints,
    this.endPointRadius = 0.04,
    required this.wallRects,
    this.holeRects = const [],
  });
}

final Map<int, MazeLevelConfig> emotionalMazeConfigs = {
  61: MazeLevelConfig(
    levelId: 61,
    startPoint: Offset(0.0859, 0.5059),
    endPoints: [
      Offset(0.6815, 0.287),
      Offset(0.6159, 0.5178),
      Offset(0.6815, 0.7983),
    ],
    endPointRadius: 0.04,
    wallRects: [
      Rect.fromLTWH(0.183, 0.1332, 0.4678, 0.0355),
      Rect.fromLTWH(0.6186, 0.1627, 0.0044, 0.114),
      Rect.fromLTWH(0.6175, 0.2685, 0.11, 0.0067),
      Rect.fromLTWH(0.6208, 0.3048, 0.1256, 0.0584),
      Rect.fromLTWH(0.6986, 0.2678, 0.03, 0.0591),
      Rect.fromLTWH(0.4775, 0.3588, 0.1878, 0.0207),
      Rect.fromLTWH(0.4797, 0.3721, 0.0456, 0.1294),
      Rect.fromLTWH(0.5653, 0.4179, 0.0877, 0.0821),
      Rect.fromLTWH(0.5219, 0.4231, 0.0545, 0.0155),
      Rect.fromLTWH(0.6297, 0.4941, 0.0189, 0.0436),
      Rect.fromLTWH(0.4764, 0.5311, 0.17, 0.0688),
      Rect.fromLTWH(0.6197, 0.1687, 0.06, 0.1072),
      Rect.fromLTWH(0.4397, 0.1982, 0.1367, 0.0363),
      Rect.fromLTWH(0.4397, 0.2315, 0.0578, 0.0237),
      Rect.fromLTWH(0.4897, 0.2264, 0.0567, 0.0111),
      Rect.fromLTWH(0.5364, 0.233, 0.04, 0.0954),
      Rect.fromLTWH(0.3853, 0.2848, 0.1611, 0.0444),
      Rect.fromLTWH(0.3897, 0.3159, 0.0478, 0.0924),
      Rect.fromLTWH(0.3197, 0.1982, 0.0767, 0.0733),
      Rect.fromLTWH(0.3175, 0.2641, 0.0811, 0.0096),
      Rect.fromLTWH(0.3853, 0.2759, 0.0155, 0.0074),
      Rect.fromLTWH(0.3775, 0.2737, 0.0155, 0.0052),
      Rect.fromLTWH(0.2375, 0.1953, 0.1189, 0.0592),
      Rect.fromLTWH(0.2386, 0.2522, 0.0411, 0.0903),
      Rect.fromLTWH(0.2386, 0.304, 0.1089, 0.0363),
      Rect.fromLTWH(0.2786, 0.398, 0.0678, 0.0939),
      Rect.fromLTWH(0.2864, 0.3403, 0.0622, 0.0599),
      Rect.fromLTWH(0.1864, 0.4009, 0.1233, 0.0621),
      Rect.fromLTWH(0.1853, 0.4623, 0.0533, 0.0296),
      Rect.fromLTWH(0.1886, 0.398, 0.1122, 0.0059),
      Rect.fromLTWH(0.1486, 0.3676, 0.0967, 0.0045),
      Rect.fromLTWH(0.1664, 0.1672, 0.0333, 0.2026),
      Rect.fromLTWH(0.0464, 0.3735, 0.0989, 0.1206),
      Rect.fromLTWH(0.043, 0.4904, 0.0267, 0.0607),
      Rect.fromLTWH(0.0675, 0.5178, 0.0778, 0.0266),
      Rect.fromLTWH(0.0997, 0.5407, 0.0467, 0.3499),
      Rect.fromLTWH(0.3897, 0.4396, 0.0456, 0.1153),
      Rect.fromLTWH(0.1864, 0.5239, 0.2311, 0.031),
      Rect.fromLTWH(0.1853, 0.5503, 0.0611, 0.148),
      Rect.fromLTWH(0.1864, 0.7293, 0.0622, 0.1235),
      Rect.fromLTWH(0.2386, 0.8003, 0.0089, 0.0511),
      Rect.fromLTWH(0.2286, 0.7841, 0.1122, 0.0554),
      Rect.fromLTWH(0.2486, 0.8321, 0.0222, 0.0207),
      Rect.fromLTWH(0.3097, 0.8373, 0.0345, 0.0621),
      Rect.fromLTWH(0.333, 0.7863, 0.01, 0.0562),
      Rect.fromLTWH(0.1375, 0.8817, 0.2222, 0.0222),
      Rect.fromLTWH(0.3508, 0.8861, 0.3267, 0.023),
      Rect.fromLTWH(0.3308, 0.8817, 0.3334, 0.014),
      Rect.fromLTWH(0.6386, 0.8122, 0.07, 0.0954),
      Rect.fromLTWH(0.6897, 0.7818, 0.0233, 0.0429),
      Rect.fromLTWH(0.6364, 0.6997, 0.0866, 0.0844),
      Rect.fromLTWH(0.5808, 0.5984, 0.1322, 0.1013),
      Rect.fromLTWH(0.2864, 0.5843, 0.1511, 0.0555),
      Rect.fromLTWH(0.3708, 0.628, 0.1722, 0.0362),
      Rect.fromLTWH(0.3686, 0.6376, 0.1244, 0.0303),
      Rect.fromLTWH(0.4808, 0.6627, 0.0634, 0.0925),
      Rect.fromLTWH(0.5575, 0.7286, 0.0411, 0.1242),
      Rect.fromLTWH(0.5375, 0.7301, 0.0344, 0.0273),
      Rect.fromLTWH(0.2886, 0.6383, 0.0389, 0.1154),
      Rect.fromLTWH(0.2864, 0.6332, 0.0089, 0.119),
      Rect.fromLTWH(0.3142, 0.6975, 0.1288, 0.0577),
      Rect.fromLTWH(0.3842, 0.7855, 0.1322, 0.0673),
      Rect.fromLTWH(0.3842, 0.753, 0.0577, 0.0532),
    ],
  ),
};