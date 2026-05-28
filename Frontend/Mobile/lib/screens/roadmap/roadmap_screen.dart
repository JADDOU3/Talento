import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activities/activity_intro_example.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/roadmap/roadmap_cubit.dart';
import '../../cubits/roadmap/roadmap_state.dart';
import '../../models/roadmap/roadmap_activity_model.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/layout/app_background.dart';

class RoadmapScreen extends StatelessWidget {
  final int kitId;
  final int childId;

  const RoadmapScreen({
    super.key,
    required this.kitId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RoadmapCubit(RoadmapService())
        ..loadRoadmap(
          kitId,
          childId,
        ),
      child: _RoadmapView(
        kitId: kitId,
        childId: childId,
      ),
    );
  }
}

class _RoadmapView extends StatelessWidget {
  final int kitId;
  final int childId;

  const _RoadmapView({
    required this.kitId,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                children: [
                  _RoadmapHeader(
                    onBack: () => Navigator.pop(context),
                    onRefresh: () {
                      context.read<RoadmapCubit>().loadRoadmap(
                        kitId,
                        childId,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: BlocBuilder<RoadmapCubit, RoadmapState>(
                      builder: (context, state) {
                        if (state is RoadmapLoading) {
                          return const _RoadmapLoadingView();
                        }

                        if (state is RoadmapError) {
                          return _RoadmapErrorView(
                            message: state.message,
                            onRetry: () {
                              context.read<RoadmapCubit>().loadRoadmap(
                                kitId,
                                childId,
                              );
                            },
                          );
                        }

                        if (state is RoadmapLoaded) {
                          if (state.activities.isEmpty) {
                            return const _RoadmapEmptyView();
                          }

                          return _RoadmapActivitiesList(
                            activities: state.activities,
                          );
                        }

                        return const SizedBox.shrink();
                      },
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

class _RoadmapHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _RoadmapHeader({
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_forward_ios_rounded,
          onTap: onBack,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'رحلة التعلّم',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'تابعي الأنشطة خطوة بخطوة',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _CircleIconButton(
          icon: Icons.refresh_rounded,
          onTap: onRefresh,
          iconColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: iconColor,
        ),
      ),
    );
  }
}

class _RoadmapActivitiesList extends StatelessWidget {
  final List<RoadmapActivityModel> activities;

  const _RoadmapActivitiesList({
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: activities.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == activities.length) {
          return const _BonusChestCard();
        }

        final activity = activities[index];

        return _RoadmapActivityCard(
          activity: activity,
          index: index,
          onTap: () => _handleActivityTap(
            context,
            activity,
          ),
        );
      },
    );
  }

  void _handleActivityTap(
      BuildContext context,
      RoadmapActivityModel activity,
      ) {
    if (activity.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('أكملي الأنشطة السابقة أولًا'),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ActivityIntroExample(),
      ),
    ).then((_) {
      context.read<RoadmapCubit>().refreshRoadmap();
    });
  }
}

class _RoadmapActivityCard extends StatelessWidget {
  final RoadmapActivityModel activity;
  final int index;
  final VoidCallback onTap;

  const _RoadmapActivityCard({
    required this.activity,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(activity.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: activity.isCurrent
                ? AppColors.primary.withValues(alpha: 0.45)
                : AppColors.border,
            width: activity.isCurrent ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _ActivityStatusIcon(
              activity: activity,
              color: statusColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityName.trim().isEmpty
                        ? 'نشاط ${index + 1}'
                        : activity.activityName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: activity.isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitleFor(activity),
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: activity.isLocked
                          ? AppColors.hint
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _ActivityImagePreview(activity: activity),
          ],
        ),
      ),
    );
  }

  String _subtitleFor(RoadmapActivityModel activity) {
    if (activity.isCompleted) {
      return 'مكتمل';
    }

    if (activity.isCurrent) {
      final levelText = activity.levelText;
      return levelText.isEmpty ? 'النشاط الحالي' : levelText;
    }

    return 'مغلق';
  }

  Color _statusColor(RoadmapActivityStatus status) {
    switch (status) {
      case RoadmapActivityStatus.completed:
        return AppColors.primary;
      case RoadmapActivityStatus.current:
        return AppColors.yellow;
      case RoadmapActivityStatus.locked:
        return AppColors.hint;
    }
  }
}

class _ActivityStatusIcon extends StatelessWidget {
  final RoadmapActivityModel activity;
  final Color color;

  const _ActivityStatusIcon({
    required this.activity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (activity.isCurrent) {
      return _PulsingStatusIcon(
        color: color,
        icon: Icons.play_arrow_rounded,
      );
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: activity.isLocked ? 0.18 : 1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        activity.isCompleted ? Icons.check_rounded : Icons.lock_rounded,
        color: activity.isLocked ? AppColors.textSecondary : AppColors.white,
        size: 28,
      ),
    );
  }
}

class _PulsingStatusIcon extends StatefulWidget {
  final Color color;
  final IconData icon;

  const _PulsingStatusIcon({
    required this.color,
    required this.icon,
  });

  @override
  State<_PulsingStatusIcon> createState() => _PulsingStatusIconState();
}

class _PulsingStatusIconState extends State<_PulsingStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
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
      scale: _scaleAnimation,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: AppColors.white,
          size: 32,
        ),
      ),
    );
  }
}

class _ActivityImagePreview extends StatelessWidget {
  final RoadmapActivityModel activity;

  const _ActivityImagePreview({
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    if (!activity.hasCoverImage) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.extension_rounded,
          color: AppColors.primary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        activity.coverImageUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.broken_image_rounded,
              color: AppColors.hint,
            ),
          );
        },
      ),
    );
  }
}

class _BonusChestCard extends StatelessWidget {
  const _BonusChestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.yellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.yellow.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.yellow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'BONUS CHEST',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapLoadingView extends StatelessWidget {
  const _RoadmapLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) {
        return Container(
          height: 92,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              _skeletonBox(
                width: 54,
                height: 54,
                radius: 27,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(
                      width: double.infinity,
                      height: 16,
                      radius: 8,
                    ),
                    const SizedBox(height: 12),
                    _skeletonBox(
                      width: 120,
                      height: 14,
                      radius: 7,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _RoadmapErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RoadmapErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'صار خطأ أثناء تحميل الرحلة',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapEmptyView extends StatelessWidget {
  const _RoadmapEmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.route_rounded,
              color: AppColors.primary,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد أنشطة بعد',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ستظهر رحلة التعلّم هنا عند إضافة الأنشطة.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}