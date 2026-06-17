import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';

class RoadmapActivityTile extends StatelessWidget {
  final RoadmapActivityModel activity;
  final int index;
  final int? childId;
  final VoidCallback onTap;

  const RoadmapActivityTile({
    super.key,
    required this.activity,
    required this.index,
    required this.onTap,
    this.childId,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = _tileColor;
    final statusColor = _statusColor;
    final rotation = _rotationForIndex(index);

    return Transform.rotate(
      angle: activity.isLocked ? rotation * 0.45 : rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(32),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: activity.isCurrent ? 188 : 170,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 11),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: activity.isCurrent
                    ? AppColors.white.withValues(alpha: 0.98)
                    : AppColors.white.withValues(alpha: 0.72),
                width: activity.isCurrent ? 2.6 : 1.7,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(
                    alpha: activity.isCurrent || activity.isCompleted
                        ? 0.30
                        : 0.18,
                  ),
                  blurRadius: activity.isCurrent || activity.isCompleted
                      ? 26
                      : 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activity.isCompleted)
                  const SizedBox(height: 27)
                else
                  _StatusBadge(
                    activity: activity,
                    color: statusColor,
                  ),
                const SizedBox(height: 6),
                _ActivityIcon(
                  activity: activity,
                  color: statusColor,
                ),
                const SizedBox(height: 8),
                Text(
                  activity.activityName.trim().isEmpty
                      ? 'نشاط ${index + 1}'
                      : activity.activityName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: activity.isCurrent ? 14.8 : 14,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: 5),
                _ActivitySubtitle(
                  activity: activity,
                  childId: childId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _tileColor {
    final colors = <Color>[
      AppColors.pink.withValues(alpha: 0.8),
      AppColors.yellow.withValues(alpha: 0.8),
      AppColors.secondary.withValues(alpha: 0.8),
      AppColors.primary.withValues(alpha: 0.8),
      const Color(0xFF48C5DC).withValues(alpha: 0.8),
    ];

    final baseColor = colors[index % colors.length];

    if (activity.isLocked) {
      return baseColor.withValues(alpha: 0.46);
    }

    // Completed and current keep their original card color.
    return baseColor;
  }

  Color get _statusColor {
    final colors = <Color>[
      AppColors.pink,
      AppColors.yellow,
      AppColors.secondary,
      AppColors.primary,
      const Color(0xFF48C5DC),
    ];

    if (activity.isCurrent || activity.isCompleted) {
      return colors[index % colors.length];
    }

    return AppColors.textPrimary;
  }

  static double _rotationForIndex(int index) {
    final rotations = <double>[-0.040, 0.034, -0.024, 0.030];
    return rotations[index % rotations.length];
  }
}

class _ActivitySubtitle extends StatelessWidget {
  final RoadmapActivityModel activity;
  final int? childId;

  const _ActivitySubtitle({
    required this.activity,
    required this.childId,
  });

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
    final color = activity.isCurrent ? AppColors.white : AppColors.textPrimary;

    return FutureBuilder<String>(
      future: _subtitle,
      initialData: _backendSubtitle,
      builder: (context, snapshot) {
        final text = snapshot.data ?? _backendSubtitle;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: activity.isCurrent
                ? AppColors.white.withValues(alpha: 0.20)
                : AppColors.white.withValues(alpha: 0.64),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontSize: 11.2,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        );
      },
    );
  }

  Future<String> get _subtitle async {
    if (activity.isCompleted) {
      return 'تم إنجازها';
    }

    if (!activity.isCurrent) {
      return 'مغلق';
    }

    if (!_isColorLab || childId == null || childId == 0) {
      return _backendSubtitle;
    }

    final localLevelNumber = await _readColorLabLocalLevelNumber();

    if (localLevelNumber == null) {
      return _backendSubtitle;
    }

    final backendLevelNumber = activity.currentLevelNumber <= 0
        ? 1
        : activity.currentLevelNumber;

    final totalLevels = activity.totalLevels <= 0 ? 1 : activity.totalLevels;

    final displayLevelNumber = localLevelNumber > backendLevelNumber
        ? localLevelNumber
        : backendLevelNumber;

    return 'المستوى $displayLevelNumber من $totalLevels';
  }

  String get _backendSubtitle {
    if (activity.isCompleted) {
      return 'تم إنجازها';
    }

    if (activity.isCurrent) {
      return activity.levelText.isEmpty ? 'النشاط الحالي' : activity.levelText;
    }

    return 'مغلق';
  }

  bool get _isColorLab {
    return activity.activityName.trim().toLowerCase() == 'color lab';
  }

  Future<int?> _readColorLabLocalLevelNumber() async {
    final key =
        'color_lab_progress_child_${childId}_activity_${activity.activityId}';

    final raw = await _storage.read(key: key);

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return null;

      final value = decoded['levelIndex'];

      int? levelIndex;

      if (value is int) {
        levelIndex = value;
      } else {
        levelIndex = int.tryParse(value?.toString() ?? '');
      }

      if (levelIndex == null || levelIndex < 0) return null;

      return levelIndex + 1;
    } catch (_) {
      return null;
    }
  }
}

class _ActivityIcon extends StatelessWidget {
  final RoadmapActivityModel activity;
  final Color color;

  const _ActivityIcon({
    required this.activity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (activity.isCurrent) {
      return _PulsingIcon(
        activity: activity,
        color: color,
      );
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(
          alpha: activity.isLocked ? 0.82 : 0.92,
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _fallbackIcon,
        color: activity.isLocked ? AppColors.textPrimary : color,
        size: 31,
      ),
    );
  }

  IconData get _fallbackIcon {
    if (activity.isCompleted) return Icons.check_rounded;
    if (activity.isCurrent) return Icons.play_arrow_rounded;
    return Icons.lock_rounded;
  }
}

class _PulsingIcon extends StatefulWidget {
  final RoadmapActivityModel activity;
  final Color color;

  const _PulsingIcon({
    required this.activity,
    required this.color,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);

    _scale = Tween<double>(
      begin: 0.94,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.96),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.36),
              blurRadius: 22,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_rounded,
          color: widget.color,
          size: 39,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final RoadmapActivityModel activity;
  final Color color;

  const _StatusBadge({
    required this.activity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final icon = activity.isCurrent
        ? Icons.auto_awesome_rounded
        : Icons.lock_rounded;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: activity.isLocked ? AppColors.textPrimary : color,
        ),
      ),
    );
  }
}