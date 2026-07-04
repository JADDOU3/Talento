import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/activities/story_spinner_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'story_spinner_stories_screen.dart';
import 'story_spinner_wheel_screen.dart';

class StorySpinnerIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const StorySpinnerIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<StorySpinnerIntro> createState() => _StorySpinnerIntroState();
}

class _StorySpinnerIntroState extends State<StorySpinnerIntro> {
  final StorySpinnerService _service = StorySpinnerService();

  bool _isPreparing = false;
  bool _isOpeningStories = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing || _isOpeningStories) return;

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
          builder: (_) => StorySpinnerWheelScreen(
            activityId: data.activityId,
            activitySessionId: activitySessionId,
            childId: data.childId,
            sessionId: data.sessionId,
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
      if (!mounted) return;

      setState(() {
        _isPreparing = false;
      });
    }
  }

  Future<void> _openStoriesScreen() async {
    if (_isPreparing || _isOpeningStories) return;

    setState(() {
      _isOpeningStories = true;
    });

    try {
      final childId = widget.childId ?? await _service.getSelectedChildId();
      final activityId = widget.activityId;

      if (activityId == null || activityId == 0) {
        throw Exception('Activity id was not provided.');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StorySpinnerStoriesScreen(
            activityId: activityId,
            childId: childId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح القصص: ${error.toString()}',
            textDirection: TextDirection.rtl,
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isOpeningStories = false;
      });
    }
  }

  Future<_StorySpinnerResolvedData> _resolveGameData() async {
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
      return _StorySpinnerResolvedData(
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

    return _StorySpinnerResolvedData(
      childId: childId,
      sessionId: sessionId,
      kitId: kitId,
      activityId: activityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ActivityIntroTemplate(
          background: const AppBackground(
            child: SizedBox.expand(),
          ),
          mascotAssetPath: 'assets/images/template_mascot.png',
          startButtonText: 'ابدأ القصة',
          replayButtonText: 'اسمع الشرح مرة أخرى',
          onStartPressed: _prepareAndStartGame,
          onReplayPressed: _prepareAndStartGame,
        ),

        Positioned(
          left: 30,
          bottom: 200,
          child: _StoriesLibraryButton(
            isLoading: _isOpeningStories,
            onPressed: _openStoriesScreen,
          ),
        ),

        if (_isPreparing || _isOpeningStories)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.18),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class _StoriesLibraryButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _StoriesLibraryButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isLoading ? null : onPressed,
          child: Container(
            padding: const EdgeInsets.fromLTRB(11, 9, 10, 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.white.withOpacity(0.98),
                  AppColors.primary.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.white.withOpacity(0.92),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.13),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.black.withOpacity(0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.14),
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(7.5),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                      : const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.primary,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'قصصي السابقة',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorySpinnerResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _StorySpinnerResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}