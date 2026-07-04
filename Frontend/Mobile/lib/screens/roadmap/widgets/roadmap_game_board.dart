import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';
import 'roadmap_activity_tile.dart';
import 'roadmap_bonus_chest.dart';
import 'roadmap_connector.dart';

class RoadmapGameBoard extends StatefulWidget {
  final List<RoadmapActivityModel> activities;
  final ValueChanged<RoadmapActivityModel> onActivityTap;
  final String mascotAssetPath;
  final int? childId;
  final int? initialActivityId;
  final int? initialActivityIndex;

  const RoadmapGameBoard({
    super.key,
    required this.activities,
    required this.onActivityTap,
    this.mascotAssetPath = 'assets/images/template_mascot.png',
    this.childId,
    this.initialActivityId,
    this.initialActivityIndex,
  });

  @override
  State<RoadmapGameBoard> createState() => _RoadmapGameBoardState();
}

class _RoadmapGameBoardState extends State<RoadmapGameBoard> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _activityKeysByIndex = {};

  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runInitialScroll();
    });
  }

  @override
  void didUpdateWidget(covariant RoadmapGameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activities != widget.activities ||
        oldWidget.childId != widget.childId ||
        oldWidget.initialActivityId != widget.initialActivityId ||
        oldWidget.initialActivityIndex != widget.initialActivityIndex) {
      _didAutoScroll = false;
      _removeStaleIndexKeys();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runInitialScroll();
      });
    }
  }

  void _removeStaleIndexKeys() {
    _activityKeysByIndex.removeWhere(
          (index, _) => index < 0 || index >= widget.activities.length,
    );
  }

  Future<void> _runInitialScroll() async {
    if (_didAutoScroll) return;

    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted || !_scrollController.hasClients) return;

    final targetIndex = _resolveTargetIndex();

    if (targetIndex != null) {
      await _scrollToActivityIndex(targetIndex);
      _didAutoScroll = true;
      return;
    }

    await _scrollToRoadStart();
    _didAutoScroll = true;
  }

  int? _resolveTargetIndex() {
    final directIndex = widget.initialActivityIndex;

    if (directIndex != null &&
        directIndex >= 0 &&
        directIndex < widget.activities.length) {
      return directIndex;
    }

    final activityId = widget.initialActivityId;

    if (activityId == null) {
      return null;
    }

    final currentIndex = widget.activities.indexWhere(
          (activity) => activity.activityId == activityId && activity.isCurrent,
    );

    if (currentIndex != -1) {
      return currentIndex;
    }

    final firstIndex = widget.activities.indexWhere(
          (activity) => activity.activityId == activityId,
    );

    return firstIndex == -1 ? null : firstIndex;
  }

  Future<void> _scrollToActivityIndex(int targetIndex) async {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    if (maxScroll <= 0 || widget.activities.length <= 1) {
      return;
    }

    final count = widget.activities.length;

    final ratioFromTop = (count - 1 - targetIndex) / (count - 1);
    final estimatedOffset = (maxScroll * ratioFromTop).clamp(0.0, maxScroll);

    await _scrollController.animateTo(
      estimatedOffset,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubic,
    );

    await Future.delayed(const Duration(milliseconds: 120));

    if (!mounted) return;

    final key = _activityKeysByIndex[targetIndex];
    final targetContext = key?.currentContext;

    if (targetContext == null) return;

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.42,
    );
  }

  Future<void> _scrollToRoadStart() async {
    if (!mounted || !_scrollController.hasClients) return;

    _scrollController.jumpTo(0);

    await Future.delayed(const Duration(milliseconds: 220));

    if (!mounted || !_scrollController.hasClients) return;

    final firstMaxScroll = _scrollController.position.maxScrollExtent;

    if (firstMaxScroll <= 0) {
      return;
    }

    await _scrollController.animateTo(
      firstMaxScroll,
      duration: const Duration(milliseconds: 1350),
      curve: Curves.easeInOutCubic,
    );

    await Future.delayed(const Duration(milliseconds: 260));

    if (!mounted || !_scrollController.hasClients) return;

    final finalMaxScroll = _scrollController.position.maxScrollExtent;

    if (finalMaxScroll > _scrollController.offset + 4) {
      await _scrollController.animateTo(
        finalMaxScroll,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  GlobalKey _keyForIndex(int index) {
    return _activityKeysByIndex.putIfAbsent(index, GlobalKey.new);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      const SizedBox(height: 18),
      const RoadmapBonusChest(),
      const SizedBox(height: 10),
    ];

    for (int visualIndex = widget.activities.length - 1;
    visualIndex >= 0;
    visualIndex--) {
      final activity = widget.activities[visualIndex];
      final originalIndex = visualIndex;
      final isRight = originalIndex.isEven;

      children.add(
        RoadmapConnector(
          isActive: !activity.isLocked,
          curveToRight: !isRight,
        ),
      );

      children.add(
        _RoadmapStep(
          isRight: isRight,
          child: KeyedSubtree(
            key: _keyForIndex(originalIndex),
            child: RoadmapActivityTile(
              activity: activity,
              index: originalIndex,
              childId: widget.childId,
              onTap: () => widget.onActivityTap(activity),
            ),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 4));

    children.add(
      _RoadStartGuide(
        mascotAssetPath: widget.mascotAssetPath,
      ),
    );

    children.add(const SizedBox(height: 16));

    return ListView(
      controller: _scrollController,
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 18),
      children: children,
    );
  }
}

class _RoadmapStep extends StatelessWidget {
  final bool isRight;
  final Widget child;

  const _RoadmapStep({
    required this.isRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isRight ? Alignment.centerRight : Alignment.centerLeft;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.only(
            right: isRight ? 10 : 0,
            left: isRight ? 0 : 10,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RoadStartGuide extends StatelessWidget {
  final String mascotAssetPath;

  const _RoadStartGuide({
    required this.mascotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 4,
            right: 72,
            top: 22,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 15, 96, 15),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.96),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.16),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'انطلق نحو أول تحدي 🚀',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'كل نشاط يفتح مهارة جديدة',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.2,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: -8,
            top: 0,
            child: Image.asset(
              mascotAssetPath,
              width: 170,
              height: 170,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: AppColors.primary,
                    size: 62,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}