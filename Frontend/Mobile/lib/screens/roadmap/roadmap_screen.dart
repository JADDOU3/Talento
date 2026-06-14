import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activities/color_lab/color_lab_launcher.dart';
import '../../activities/conflict_resolution/conflict_resolution_intro.dart';
import '../../activities/mirror_mind/mirror_mind_intro.dart';
import '../../activities/pattern_hacker/pattern_hacker_intro.dart';
import '../../core/theme/app_colors.dart';
import '../../cubits/roadmap/roadmap_cubit.dart';
import '../../cubits/roadmap/roadmap_state.dart';
import '../../models/roadmap/roadmap_activity_model.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/roadmap_game_board.dart';
import 'widgets/roadmap_header.dart';
import 'widgets/roadmap_state_views.dart';

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
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                children: [
                  RoadmapHeader(
                    onBack: () => Navigator.pop(context),
                    onRefresh: () {
                      context.read<RoadmapCubit>().loadRoadmap(
                        kitId,
                        childId,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: BlocBuilder<RoadmapCubit, RoadmapState>(
                      builder: (context, state) {
                        if (state is RoadmapLoading) {
                          return const RoadmapLoadingView();
                        }

                        if (state is RoadmapError) {
                          return RoadmapErrorView(
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
                            return const RoadmapEmptyView();
                          }

                          return RoadmapGameBoard(
                            activities: state.activities,
                            onActivityTap: (activity) {
                              _handleActivityTap(
                                context,
                                activity,
                              );
                            },
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

  void _handleActivityTap(
      BuildContext context,
      RoadmapActivityModel activity,
      ) {
    if (activity.isLocked) {
      _showMessage(context, 'أكملي الأنشطة السابقة أولًا');
      return;
    }

    final activityName = activity.activityName.trim().toLowerCase();

    if (activityName == 'mirror mind') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MirrorMindIntro(
            childId: childId,
            kitId: kitId,
            activityId: activity.activityId,
            initialLevelNumber: activity.currentLevelNumber <= 0
                ? 1
                : activity.currentLevelNumber,
          ),
        ),
      ).then((_) => _refreshRoadmapIfMounted(context));
      return;
    }

    if (activityName == 'color lab') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ColorLabLauncher(
            activityId: activity.activityId,
            kitId: kitId,
            childId: childId,
          ),
        ),
      ).then((_) => _refreshRoadmapIfMounted(context));
      return;
    }

    if (activityName == 'pattern hacker') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatternHackerIntro(
            childId: childId,
            kitId: kitId,
            activityId: activity.activityId,
            initialLevelNumber: activity.currentLevelNumber <= 0
                ? 1
                : activity.currentLevelNumber,
          ),
        ),
      ).then((_) => _refreshRoadmapIfMounted(context));
      return;
    }

    if (activityName == 'conflict resolution cards') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConflictResolutionIntro(
            childId: childId,
            kitId: kitId,
            activityId: activity.activityId,
            initialLevelNumber: activity.currentLevelNumber <= 0
                ? 1
                : activity.currentLevelNumber,
          ),
        ),
      ).then((_) => _refreshRoadmapIfMounted(context));
      return;
    }

    _showMessage(
      context,
      'النشاط "${activity.activityName}" غير جاهز بعد',
    );
  }

  void _refreshRoadmapIfMounted(BuildContext context) {
    if (context.mounted) {
      context.read<RoadmapCubit>().loadRoadmap(kitId, childId);
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}