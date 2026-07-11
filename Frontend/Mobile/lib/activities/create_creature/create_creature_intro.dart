import 'package:flutter/material.dart';

import '../../shared/layout/animated_background.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/activities/create_creature_service.dart';
import '../../shared/widgets/activity_template/activity_intro_template.dart';
import 'create_creature_gender_hair_screen.dart';
import 'create_creature_stories_screen.dart';

class CreateCreatureIntro extends StatefulWidget {
  final int? childId;
  final int? sessionId;
  final int? kitId;
  final int? activityId;

  const CreateCreatureIntro({
    super.key,
    this.childId,
    this.sessionId,
    this.kitId,
    this.activityId,
  });

  @override
  State<CreateCreatureIntro> createState() => _CreateCreatureIntroState();
}

class _CreateCreatureIntroState extends State<CreateCreatureIntro> {
  final CreateCreatureService _createCreatureService = CreateCreatureService();

  bool _isPreparing = false;
  bool _isOpeningStories = false;

  Future<void> _prepareAndStartGame() async {
    if (_isPreparing || _isOpeningStories) return;

    setState(() {
      _isPreparing = true;
    });

    try {
      print('CREATE CREATURE: start pressed');
      print('CREATE CREATURE: resolving game data...');

      final resolvedData = await _resolveGameData();

      print('CREATE CREATURE: resolved childId = ${resolvedData.childId}');
      print('CREATE CREATURE: resolved sessionId = ${resolvedData.sessionId}');
      print('CREATE CREATURE: resolved kitId = ${resolvedData.kitId}');
      print('CREATE CREATURE: resolved activityId = ${resolvedData.activityId}');
      print('CREATE CREATURE: creating activity session...');

      final activitySessionId =
      await _createCreatureService.createActivitySession(
        activityId: resolvedData.activityId,
        sessionId: resolvedData.sessionId,
      );

      print(
          'CREATE CREATURE: created activitySessionId = $activitySessionId');

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateCreatureGenderHairScreen(
            activityId: resolvedData.activityId,
            activitySessionId: activitySessionId,
            childId: resolvedData.childId,
            sessionId: resolvedData.sessionId,
          ),
        ),
      );
    } catch (error) {
      print('CREATE CREATURE START ERROR: $error');

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
      final childId = widget.childId ??
          await _createCreatureService.getSelectedChildId();
      final activityId = widget.activityId;

      if (activityId == null || activityId == 0) {
        throw Exception('Activity id was not provided.');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateCreatureStoriesScreen(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
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

  Future<_CreateCreatureResolvedData> _resolveGameData() async {
    final childId =
        widget.childId ?? await _createCreatureService.getSelectedChildId();

    final sessionIdFromWidget = widget.sessionId;
    final kitIdFromWidget = widget.kitId;
    final activityIdFromWidget = widget.activityId;

    if (kitIdFromWidget == null || kitIdFromWidget == 0) {
      throw Exception('Kit id was not provided.');
    }

    if (activityIdFromWidget == null || activityIdFromWidget == 0) {
      throw Exception('Activity id was not provided.');
    }

    if (sessionIdFromWidget != null && sessionIdFromWidget != 0) {
      return _CreateCreatureResolvedData(
        childId: childId,
        sessionId: sessionIdFromWidget,
        kitId: kitIdFromWidget,
        activityId: activityIdFromWidget,
      );
    }

    print(
        'CREATE CREATURE: getting latest session for childId = $childId');

    final latestSession =
    await _createCreatureService.getLatestSessionForChild(childId);

    int sessionId = 0;

    if (latestSession != null) {
      sessionId = _createCreatureService.readSessionId(latestSession);
      print('CREATE CREATURE: latest sessionId = $sessionId');
    }

    if (sessionId == 0) {
      print(
          'CREATE CREATURE: no latest session, creating new session...');
      sessionId = await _createCreatureService.createSession(
        childId: childId,
        kitId: kitIdFromWidget,
      );
      print('CREATE CREATURE: created sessionId = $sessionId');
    }

    if (sessionId == 0) {
      throw Exception('Session id was not found or created.');
    }

    return _CreateCreatureResolvedData(
      childId: childId,
      sessionId: sessionId,
      kitId: kitIdFromWidget,
      activityId: activityIdFromWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ActivityIntroTemplate(
          activityId: widget.activityId,
          background: const AnimatedBackground(
            child: SizedBox.expand(),
          ),
          mascotAssetPath: 'assets/images/template_mascot.png',
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

class _CreateCreatureResolvedData {
  final int childId;
  final int sessionId;
  final int kitId;
  final int activityId;

  const _CreateCreatureResolvedData({
    required this.childId,
    required this.sessionId,
    required this.kitId,
    required this.activityId,
  });
}