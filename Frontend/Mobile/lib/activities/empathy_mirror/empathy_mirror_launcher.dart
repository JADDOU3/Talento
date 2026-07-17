import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/activities/color_lab_context_service.dart';
import '../../shared/layout/app_background.dart';
import 'empathy_mirror_intro.dart';

/// Resolves the game context (child → kit → activity → session →
/// activitySession) then shows EmpathyMirrorIntro.
/// Open THIS from the roadmap.
class EmpathyMirrorLauncher extends StatefulWidget {
  final int activityId;
  final int kitId;
  final int childId;

  const EmpathyMirrorLauncher({
    super.key,
    required this.activityId,
    required this.kitId,
    required this.childId,
  });

  @override
  State<EmpathyMirrorLauncher> createState() =>
      _EmpathyMirrorLauncherState();
}

class _EmpathyMirrorLauncherState
    extends State<EmpathyMirrorLauncher> {
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
          builder: (_) => EmpathyMirrorIntro(
            activityId: ctx.activityId,
            activitySessionId: ctx.activitySessionId,
            childId: ctx.childId,
            sessionId: ctx.sessionId,
            startLevelId: ctx.startLevelId,
            startLevelNumber: ctx.startLevelNumber,
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
