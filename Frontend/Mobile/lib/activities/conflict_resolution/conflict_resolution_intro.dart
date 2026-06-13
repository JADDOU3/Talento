import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/activities/conflict_resolution_service.dart';
import '../../services/tts_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/button.dart';
import 'conflict_resolution_video_screen.dart';

class ConflictResolutionIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;
  final int initialLevelNumber;

  const ConflictResolutionIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
    this.initialLevelNumber = 1,
  });

  @override
  State<ConflictResolutionIntro> createState() =>
      _ConflictResolutionIntroState();
}

class _ConflictResolutionIntroState extends State<ConflictResolutionIntro> {
  final ConflictResolutionService _service = ConflictResolutionService();
  final TtsService _tts = TtsService();

  bool _isPreparing = false;

  static const String _introVoice =
      'مرحباً يا بطل. سنشاهد موقفاً قصيراً، ثم نختار البطاقة المناسبة ونمسح رمزها.';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _tts.speak(_introVoice);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing) return;

    setState(() {
      _isPreparing = true;
    });

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
          builder: (_) => ConflictResolutionVideoScreen(
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
      if (mounted) {
        setState(() {
          _isPreparing = false;
        });
      }
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
      sessionId = await _service.createSession(
        childId: childId,
        kitId: kitId,
      );
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

  void _replayExplanation() {
    _tts.speak(_introVoice);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.22),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.diversity_3_rounded,
                      color: AppColors.primary,
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حلّ النزاعات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'DGAgnadeen',
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'شاهدي الموقف، ثم اختاري البطاقة المناسبة من الكِت وامسحي رمز QR الخاص بها.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  ActivityTemplateButton(
                    text: _isPreparing ? 'جاري التحضير...' : 'ابدأ',
                    backgroundColor: AppColors.primary,
                    onPressed: _isPreparing ? () {} : _prepareAndStartGame,
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: _replayExplanation,
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('إعادة الشرح'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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