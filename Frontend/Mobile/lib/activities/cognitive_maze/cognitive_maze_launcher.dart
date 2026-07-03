import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/activities/color_lab_context_service.dart';
import '../../shared/layout/app_background.dart';
import 'cognitive_maze_intro.dart';

/// Prepares the Cognitive Maze session, then shows CognitiveMazeIntro.
///
/// Reuses ColorLabContextService.resolveFromKnown — the entry pipeline
/// (selected child → kit → progress → session → activity session) is
/// identical across maze/colour activities, so there's no reason to
/// duplicate it. Open THIS screen from the roadmap.
class CognitiveMazeLauncher extends StatefulWidget {
final int activityId;
final int kitId;
final int childId;
final int? initialLevelNumber;

const CognitiveMazeLauncher({
super.key,
required this.activityId,
required this.kitId,
required this.childId,
this.initialLevelNumber,
});

@override
State<CognitiveMazeLauncher> createState() => _CognitiveMazeLauncherState();
}

class _CognitiveMazeLauncherState extends State<CognitiveMazeLauncher> {
  final ColorLabContextService _service = ColorLabContextService();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final ctx = await _service.resolveFromKnown(
        activityId: widget.activityId,
        kitId: widget.kitId,
        childId: widget.childId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CognitiveMazeIntro(
            activityId: ctx.activityId,
            activitySessionId: ctx.activitySessionId,
            childId: ctx.childId,
            sessionId: ctx.sessionId,
            startLevelId: ctx.startLevelId,
            startLevelNumber: widget.initialLevelNumber ?? ctx.startLevelNumber,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Center(
            child: _loading
                ? const CircularProgressIndicator()
                : _buildError(),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 52, color: AppColors.hint),
          const SizedBox(height: 14),
          Text(
            _error ?? 'حدث خطأ',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _prepare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}