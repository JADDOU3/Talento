import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

/// BeyondSection
/// A playful, colorful "talent report card" for the four intelligences
/// behind Talento. Each pillar is its own little world: a tilted sticker
/// icon, a gradient-filled radar chart, floating decorative shapes, and a
/// bouncy hover/tap interaction — built to feel like a kids' product, not
/// a corporate slide.
///
/// Bilingual (AR/EN) + RTL, same pattern as before.
class BeyondSection extends StatefulWidget {
  const BeyondSection({super.key});

  @override
  State<BeyondSection> createState() => _BeyondSectionState();
}

class _BeyondSectionState extends State<BeyondSection> {
  int? _expandedIndex;

  // TODO(i18n): migrate into .arb files when ready.
  static const _i18n = {
    'ar': {
      'eyebrow': '✨ إطار الذكاءات الأربعة',
      'measuresLabel': 'يقيس',
      'combinesLabel': 'يجمع بين',
      'pillars': [
        {
          'emoji': '🧠',
          'combines': ['لغوي', 'منطقي', 'مكاني', 'علمي'],
          'measures': {
            'التفكير المنطقي': 0.86,
            'التعرف على الأنماط': 0.78,
            'حل المشكلات': 0.91,
            'الاستنتاج': 0.74,
          },
        },
        {
          'emoji': '🤸',
          'combines': ['جسدي', 'حسي', 'طبيعي'],
          'measures': {
            'التوازن': 0.8,
            'التحكم الحركي': 0.88,
            'التمييز الحسي': 0.72,
            'التفاعل مع المواد': 0.83,
          },
        },
        {
          'emoji': '💛',
          'combines': ['عاطفي', 'اجتماعي', 'شخصي', 'بين شخصي'],
          'measures': {
            'التعاطف': 0.9,
            'التعاون': 0.84,
            'اتخاذ القرار الاجتماعي': 0.77,
          },
        },
        {
          'emoji': '🎨',
          'combines': ['موسيقي', 'فني', 'ابتكاري'],
          'measures': {
            'التسلسل السردي': 0.81,
            'التعبير الإبداعي': 0.93,
            'إنتاج الأفكار': 0.76,
            'الخيال': 0.95,
          },
        },
      ],
    },
    'en': {
      'eyebrow': '✨ The Four Intelligence Framework',
      'measuresLabel': 'Measures',
      'combinesLabel': 'Combines',
      'pillars': [
        {
          'emoji': '🧠',
          'combines': ['Linguistic', 'Logical', 'Spatial', 'Scientific'],
          'measures': {
            'Logical reasoning': 0.86,
            'Pattern recognition': 0.78,
            'Problem solving': 0.91,
            'Inference': 0.74,
          },
        },
        {
          'emoji': '🤸',
          'combines': ['Bodily', 'Sensory', 'Naturalistic'],
          'measures': {
            'Balance': 0.8,
            'Motor control': 0.88,
            'Sensory discrimination': 0.72,
            'Material interaction': 0.83,
          },
        },
        {
          'emoji': '💛',
          'combines': ['Emotional', 'Social', 'Personal', 'Interpersonal'],
          'measures': {
            'Empathy': 0.9,
            'Cooperation': 0.84,
            'Social decision-making': 0.77,
          },
        },
        {
          'emoji': '🎨',
          'combines': ['Musical', 'Artistic', 'Innovative'],
          'measures': {
            'Narrative sequencing': 0.81,
            'Creative expression': 0.93,
            'Idea generation': 0.76,
            'Imagination': 0.95,
          },
        },
      ],
    },
  };

  static const _gradients = [
    [AppColors.teal, AppColors.cartTeal],       // Cognitive
    [AppColors.yellow, Color(0xFFFFE082)],      // Physical (Using yellow + lighter shade)
    [AppColors.coral, Color(0xFFFF9E9E)],       // Emotional (Using coral + lighter shade)
    [Color(0xFF1E3A8A), Color(0xFF60A5FA)], // Creative
  ];

  static const _tilts = [-0.035, 0.03, -0.025, 0.035];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'ar';
    final t = _i18n[lang]!;
    final pillarsData = t['pillars'] as List;

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100 ? 4 : (width > 700 ? 2 : 1);

    final icons = [
      Icons.psychology_alt_rounded,
      Icons.accessibility_new_rounded,
      Icons.favorite_rounded,
      Icons.palette_rounded,
    ];
    final titles = [l10n.cognitiveTitle, l10n.physicalTitle, l10n.emotionalTitle, l10n.creativeTitle];
    final descs = [l10n.cognitiveDesc, l10n.physicalDesc, l10n.emotionalDesc, l10n.creativeDesc];

    final pillars = List.generate(4, (i) {
      final raw = pillarsData[i] as Map;
      final measures = (raw['measures'] as Map).map((k, v) => MapEntry(k as String, v as double));
      return _Pillar(
        title: titles[i],
        desc: descs[i],
        icon: icons[i],
        emoji: raw['emoji'] as String,
        gradient: _gradients[i],
        tilt: _tilts[i],
        combines: List<String>.from(raw['combines']),
        measures: measures,
      );
    });

    return Directionality(
      textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: Stack(
          children: [
            // Decorative floating blobs for energy/fun, kept subtle.
            const Positioned(top: 20, left: -40, child: _Blob(color: AppColors.teal, size: 160)),
            const Positioned(top: 160, right: -50, child: _Blob(color: AppColors.coral, size: 200)),
            const Positioned(bottom: 10, left: 60, child: _Blob(color: AppColors.yellow, size: 120)),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 90, horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.teal, AppColors.cartForestGreen]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Text(
                      t['eyebrow'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.frameworkTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      l10n.frameworkSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 17, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 64),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pillars.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 32,
                      crossAxisSpacing: 28,
                      childAspectRatio: crossAxisCount == 1 ? 1.0 : 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final p = pillars[index];
                      final isExpanded = _expandedIndex == index;
                      return _PillarCard(
                        pillar: p,
                        expanded: isExpanded,
                        combinesLabel: t['combinesLabel'] as String,
                        measuresLabel: t['measuresLabel'] as String,
                        onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withOpacity(0.22), color.withOpacity(0.0)]),
        ),
      ),
    );
  }
}

class _Pillar {
  final String title;
  final String desc;
  final IconData icon;
  final String emoji;
  final List<Color> gradient;
  final double tilt;
  final List<String> combines;
  final Map<String, double> measures;

  _Pillar({
    required this.title,
    required this.desc,
    required this.icon,
    required this.emoji,
    required this.gradient,
    required this.tilt,
    required this.combines,
    required this.measures,
  });
}

class _PillarCard extends StatefulWidget {
  final _Pillar pillar;
  final bool expanded;
  final String combinesLabel;
  final String measuresLabel;
  final VoidCallback onTap;

  const _PillarCard({
    required this.pillar,
    required this.expanded,
    required this.combinesLabel,
    required this.measuresLabel,
    required this.onTap,
  });

  @override
  State<_PillarCard> createState() => _PillarCardState();
}

class _PillarCardState extends State<_PillarCard> {
  bool _hovering = false;
  Color get _accent => widget.pillar.gradient.first;

  @override
  Widget build(BuildContext context) {
    final p = widget.pillar;
    final lift = _hovering || widget.expanded;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()
            ..translate(0.0, lift ? -10.0 : 0.0)
            ..rotateZ(lift ? 0.0 : p.tilt),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _accent.withOpacity(lift ? 0.5 : 0.18), width: lift ? 1.6 : 1.2),
            boxShadow: [
              BoxShadow(
                color: _accent.withOpacity(lift ? 0.32 : 0.12),
                blurRadius: lift ? 30 : 14,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            children: [
              // Colorful gradient header strip with a tilted emoji sticker.
              // Inside _PillarCardState build method, replace the Header Container:
              Container(
                height: 92,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: p.gradient,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Tilted sticker emoji in the top corner
                    Positioned(
                      top: 10,
                      right: 15,
                      child: Transform.rotate(
                        angle: 0.25,
                        child: Text(p.emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),

                    // 2. The main icon in the center circle
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          p.icon,
                          color: _accent,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  children: [
                    Text(
                      p.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _accent),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 140,
                      width: 140,
                      child: CustomPaint(
                        painter: _RadarPainter(
                          values: p.measures.values.toList(),
                          gradient: p.gradient,
                          animate: lift,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      p.desc,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 8),

                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: widget.expanded ? 0.5 : 0,
                      child: Icon(Icons.expand_circle_down_rounded, color: _accent.withOpacity(0.7), size: 22),
                    ),

                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: widget.expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      firstChild: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          children: [
                            Text(
                              widget.combinesLabel,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _accent),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: p.combines
                                  .map((c) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    _accent.withOpacity(0.15),
                                    _accent.withOpacity(0.06),
                                  ]),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: _accent.withOpacity(0.25)),
                                ),
                                child: Text(c,
                                    style: TextStyle(fontSize: 10.5, color: _accent, fontWeight: FontWeight.w700)),
                              ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox(width: double.infinity),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Colorful gradient-filled radar chart — the "talent report card" visual.
class _RadarPainter extends CustomPainter {
  final List<double> values; // 0..1
  final List<Color> gradient;
  final bool animate;

  _RadarPainter({required this.values, required this.gradient, this.animate = false});

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n < 3) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 14;

    final webPaint = Paint()
      ..color = gradient.first.withOpacity(0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int ring = 1; ring <= 3; ring++) {
      _drawDottedCircle(canvas, center, radius * ring / 3, webPaint);
    }

    final spokePaint = Paint()
      ..color = gradient.first.withOpacity(0.22)
      ..strokeWidth = 1;
    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / n);
      final outer = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      _drawDashedLine(canvas, center, outer, spokePaint);
      final v = values[i].clamp(0.0, 1.0);
      points.add(Offset(center.dx + radius * v * math.cos(angle), center.dy + radius * v * math.sin(angle)));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      path.lineTo(pt.dx, pt.dy);
    }
    path.close();

    final fillShader = SweepGradient(
      colors: [...gradient, gradient.first],
      center: Alignment.center,
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(path, Paint()..shader = fillShader..color = Colors.white.withOpacity(animate ? 0.85 : 0.6));
    canvas.drawPath(
      path,
      Paint()
        ..shader = fillShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    for (final pt in points) {
      canvas.drawCircle(pt, 3.6, Paint()..color = gradient.first);
      canvas.drawCircle(
        pt,
        3.6,
        Paint()
          ..color = AppColors.cardBackground
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _drawDottedCircle(Canvas canvas, Offset center, double r, Paint paint) {
    const dashCount = 60;
    for (int i = 0; i < dashCount; i++) {
      if (i % 2 != 0) continue;
      final a1 = 2 * math.pi * i / dashCount;
      final a2 = 2 * math.pi * (i + 1) / dashCount;
      canvas.drawLine(
        Offset(center.dx + r * math.cos(a1), center.dy + r * math.sin(a1)),
        Offset(center.dx + r * math.cos(a2), center.dy + r * math.sin(a2)),
        paint,
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 4.0, gapLength = 3.0;
    final total = (end - start).distance;
    final direction = (end - start) / total;
    double covered = 0;
    while (covered < total) {
      final next = math.min(covered + dashLength, total);
      canvas.drawLine(start + direction * covered, start + direction * next, paint);
      covered = next + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.animate != animate;
}