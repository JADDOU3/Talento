import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/activities/pattern_hacker_service.dart';
import '../../services/tts_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/button.dart';
import 'pattern_hacker_game_screen.dart';

/// SCREEN 01 — themed "digital detective room" entry.
/// Tonky enters through a portal, circles in, gets scanned, then settles.
/// Voice lines play on entry; the small button replays the explanation.
class PatternHackerIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const PatternHackerIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<PatternHackerIntro> createState() => _PatternHackerIntroState();
}

class _PatternHackerIntroState extends State<PatternHackerIntro>
    with TickerProviderStateMixin {
  final PatternHackerService _service = PatternHackerService();
  final TtsService _tts = TtsService();

  late final AnimationController _entrance;
  late final AnimationController _ambient;

  bool _isPreparing = false;

  static const String _introVoice =
      'مرحباً أيها المحقق الصغير. اليوم سنكتشف أسرار الأنماط. هل أنت مستعد؟';

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Let the portal open first, then speak.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _tts.speak(_introVoice);
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    _tts.stop();
    super.dispose();
  }

  void _replayExplanation() {
    _entrance.forward(from: 0);
    _tts.speak(_introVoice);
  }

  /// Eased 0->1 progress for a stage of the entrance timeline.
  double _stage(double begin, double end, {Curve curve = Curves.easeOut}) {
    final raw = ((_entrance.value - begin) / (end - begin)).clamp(0.0, 1.0);
    return curve.transform(raw);
  }

  // ---------------------------------------------------------------------------
  // Game start (context resolution — unchanged behaviour)
  // ---------------------------------------------------------------------------

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;
    setState(() => _isPreparing = true);

    try {
      final data = await _resolveGameData();

      final activitySessionId = await _service.createActivitySession(
        activityId: data.activityId,
        sessionId: data.sessionId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatternHackerGameScreen(
            activityId: data.activityId,
            activitySessionId: activitySessionId,
            childId: data.childId,
            sessionId: data.sessionId,
            initialLevelNumber: widget.initialLevelNumber,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر بدء النشاط: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPreparing = false);
    }
  }

  Future<_ResolvedData> _resolveGameData() async {
    final childId = widget.childId ?? await _service.getSelectedChildId();
    final kitId = widget.kitId;
    final activityId = widget.activityId;

    if (kitId == null || kitId == 0) {
      throw Exception('Kit id was not provided.');
    }
    if (activityId == null || activityId == 0) {
      throw Exception('Activity id was not provided.');
    }

    if (widget.sessionId != null && widget.sessionId != 0) {
      return _ResolvedData(
        childId: childId,
        sessionId: widget.sessionId!,
        kitId: kitId,
        activityId: activityId,
      );
    }

    final latestSession = await _service.getLatestSessionForChild(childId);
    int sessionId = 0;
    if (latestSession != null) {
      sessionId = _service.readSessionId(latestSession);
    }
    if (sessionId == 0) {
      sessionId = await _service.createSession(childId: childId, kitId: kitId);
    }
    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _ResolvedData(
      childId: childId,
      sessionId: sessionId,
      kitId: kitId,
      activityId: activityId,
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: AppBackground(child: SizedBox.expand())),

            // Floating pattern examples drifting in the background.
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, _) => _FloatingPatterns(t: _ambient.value),
              ),
            ),

            SafeArea(
              child: AnimatedBuilder(
                animation: Listenable.merge([_entrance, _ambient]),
                builder: (context, _) {
                  final titleOpacity = _stage(0.40, 0.70);
                  final buttons = _stage(0.78, 1.0);
                  final bob = math.sin(_ambient.value * 2 * math.pi) * 6;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: titleOpacity,
                          child: Column(
                            children: [
                              Text(
                                'محقّق الأنماط',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'DGAgnadeen',
                                  fontSize: size.width * 0.085,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'هيا نكتشف أسرار الأنماط!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'ArialRounded',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: Center(
                            child: _PortalMascot(
                              portalScale: _stage(0.0, 0.35, curve: Curves.easeOutBack),
                              portalFade: 1 - _stage(0.5, 0.95),
                              appear: _stage(0.2, 0.7, curve: Curves.easeOutBack),
                              scan: _stage(0.55, 0.92),
                              bob: bob,
                              width: size.width * 0.62,
                            ),
                          ),
                        ),

                        Opacity(
                          opacity: buttons,
                          child: Transform.translate(
                            offset: Offset(0, (1 - buttons) * 30),
                            child: Column(
                              children: [
                                ActivityTemplateButton(
                                  text: 'ابدأ المغامرة',
                                  onPressed: _prepareAndStartGame,
                                  backgroundColor: AppColors.primary,
                                  height: 78,
                                  borderRadius: 28,
                                  fontSize: size.width * 0.075,
                                  textStyle: const TextStyle(
                                    fontFamily: 'DGAgnadeen',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.07,
                                  ),
                                  child: ActivityTemplateButton(
                                    text: 'اسمع الشرح',
                                    onPressed: _replayExplanation,
                                    backgroundColor: AppColors.pink,
                                    height: 58,
                                    borderRadius: 26,
                                    fontSize: size.width * 0.042,
                                    textStyle: const TextStyle(
                                      fontFamily: 'DGAgnadeen',
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (_isPreparing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The portal rings + Tonky + scan line.
class _PortalMascot extends StatelessWidget {
  final double portalScale;
  final double portalFade;
  final double appear;
  final double scan;
  final double bob;
  final double width;

  const _PortalMascot({
    required this.portalScale,
    required this.portalFade,
    required this.appear,
    required this.scan,
    required this.bob,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final mascotHeight = width;

    return SizedBox(
      width: width * 1.25,
      height: mascotHeight * 1.25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Portal glow rings.
          Opacity(
            opacity: portalFade.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.4 + portalScale,
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.35),
                      AppColors.secondary.withOpacity(0.0),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tonky entering: scales up, drifts down into place, with a bob.
          Transform.translate(
            offset: Offset(0, (1 - appear) * -90 + bob),
            child: Transform.rotate(
              angle: (1 - appear) * -0.5,
              child: Transform.scale(
                scale: (0.2 + appear * 0.8).clamp(0.0, 1.0),
                child: Image.asset(
                  'assets/images/template_mascot.png',
                  width: width,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.smart_toy_rounded,
                    size: width * 0.6,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Scan line sweeping over Tonky once.
          if (scan > 0 && scan < 1)
            Positioned(
              top: scan * mascotHeight,
              child: Container(
                width: width * 0.95,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.0),
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.0),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.7),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Faint pattern examples drifting in the background.
class _FloatingPatterns extends StatelessWidget {
  final double t;

  const _FloatingPatterns({required this.t});

  static const List<String> _examples = [
    '▲  ■  ▲  ■  ؟',
    '1  2  1  2  ؟',
    '●  ○  ●  ○  ؟',
    '★  ❤  ★  ❤  ؟',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        for (int i = 0; i < _examples.length; i++)
          Positioned(
            left: (i.isEven ? 0.06 : 0.42) * size.width,
            top: (0.12 + i * 0.2) * size.height +
                math.sin((t + i * 0.25) * 2 * math.pi) * 10,
            child: Opacity(
              opacity: 0.10,
              child: Text(
                _examples[i],
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _ResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}
