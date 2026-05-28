import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';

class RoadmapActivityTile extends StatelessWidget {
  final RoadmapActivityModel activity;
  final int index;
  final VoidCallback onTap;

  const RoadmapActivityTile({
    super.key,
    required this.activity,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileColor = _tileColor;
    final statusColor = _statusColor;
    final rotation = _rotationForIndex(index);

    return Transform.rotate(
      angle: activity.isLocked ? 0 : rotation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: activity.isCurrent ? 186 : 170,
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: activity.isCurrent
                    ? AppColors.white.withValues(alpha: 0.95)
                    : AppColors.white.withValues(alpha: 0.65),
                width: activity.isCurrent ? 2.4 : 1.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(
                    alpha: activity.isCurrent ? 0.35 : 0.18,
                  ),
                  blurRadius: activity.isCurrent ? 28 : 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StatusBadge(
                  activity: activity,
                  color: statusColor,
                ),
                const SizedBox(height: 10),
                _ActivityIcon(
                  activity: activity,
                  color: statusColor,
                ),
                const SizedBox(height: 10),
                Text(
                  activity.activityName.trim().isEmpty
                      ? 'نشاط ${index + 1}'
                      : activity.activityName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: activity.isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: activity.isLocked
                        ? AppColors.hint
                        : AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _tileColor {
    if (activity.isLocked) {
      return AppColors.inputFill.withValues(alpha: 0.92);
    }

    final colors = <Color>[
      AppColors.primary.withValues(alpha: 0.92),
      AppColors.pink.withValues(alpha: 0.90),
      AppColors.yellow.withValues(alpha: 0.92),
      const Color(0xFF48C5DC).withValues(alpha: 0.92),
    ];

    if (activity.isCompleted) {
      return AppColors.primary.withValues(alpha: 0.92);
    }

    if (activity.isCurrent) {
      return AppColors.pink.withValues(alpha: 0.92);
    }

    return colors[index % colors.length];
  }

  Color get _statusColor {
    if (activity.isCompleted) return AppColors.primary;
    if (activity.isCurrent) return AppColors.pink;
    return AppColors.hint;
  }

  String get _subtitle {
    if (activity.isCompleted) {
      return 'مكتمل';
    }

    if (activity.isCurrent) {
      return activity.levelText.isEmpty ? 'النشاط الحالي' : activity.levelText;
    }

    return 'مغلق';
  }

  static double _rotationForIndex(int index) {
    final rotations = <double>[-0.045, 0.04, -0.025, 0.035];
    return rotations[index % rotations.length];
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
      return _PulsingIcon(activity: activity);
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: activity.isLocked ? 0.58 : 0.9),
        shape: BoxShape.circle,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (activity.hasCoverImage && !activity.isLocked) {
      return ClipOval(
        child: Image.network(
          activity.coverImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            _fallbackIcon,
            color: color,
            size: 34,
          ),
        ),
      );
    }

    return Icon(
      _fallbackIcon,
      color: activity.isLocked ? AppColors.hint : color,
      size: 34,
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

  const _PulsingIcon({
    required this.activity,
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
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withValues(alpha: 0.34),
              blurRadius: 22,
              spreadRadius: 4,
            ),
          ],
        ),
        child: widget.activity.hasCoverImage
            ? ClipOval(
          child: Image.network(
            widget.activity.coverImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.pink,
                size: 40,
              );
            },
          ),
        )
            : const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.pink,
          size: 40,
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
    final icon = activity.isCompleted
        ? Icons.check_rounded
        : activity.isCurrent
        ? Icons.auto_awesome_rounded
        : Icons.lock_rounded;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 17,
          color: color,
        ),
      ),
    );
  }
}