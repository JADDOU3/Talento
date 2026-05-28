import 'package:flutter/material.dart';

import '../../../models/roadmap/roadmap_activity_model.dart';
import 'roadmap_activity_tile.dart';
import 'roadmap_bonus_chest.dart';
import 'roadmap_connector.dart';

class RoadmapGameBoard extends StatefulWidget {
  final List<RoadmapActivityModel> activities;
  final ValueChanged<RoadmapActivityModel> onActivityTap;

  const RoadmapGameBoard({
    super.key,
    required this.activities,
    required this.onActivityTap,
  });

  @override
  State<RoadmapGameBoard> createState() => _RoadmapGameBoardState();
}

class _RoadmapGameBoardState extends State<RoadmapGameBoard> {
  late final ScrollController _scrollController;
  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentActivity();
    });
  }

  @override
  void didUpdateWidget(covariant RoadmapGameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.activities != widget.activities) {
      _didAutoScroll = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentActivity();
      });
    }
  }

  void _scrollToCurrentActivity() {
    if (_didAutoScroll || !_scrollController.hasClients) return;

    final currentIndex = widget.activities.indexWhere(
          (activity) => activity.isCurrent,
    );

    if (currentIndex <= 0) {
      _didAutoScroll = true;
      return;
    }

    final targetOffset = (currentIndex * 220.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );

    _didAutoScroll = true;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    for (int index = 0; index < widget.activities.length; index++) {
      final activity = widget.activities[index];
      final isRight = index.isEven;

      children.add(
        Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              right: isRight ? 8 : 0,
              left: isRight ? 0 : 8,
            ),
            child: RoadmapActivityTile(
              activity: activity,
              index: index,
              onTap: () => widget.onActivityTap(activity),
            ),
          ),
        ),
      );

      children.add(
        RoadmapConnector(
          isActive: !activity.isLocked,
          curveToRight: isRight,
        ),
      );
    }

    children.add(const SizedBox(height: 4));
    children.add(const RoadmapBonusChest());
    children.add(const SizedBox(height: 36));

    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(6, 18, 6, 24),
      children: children,
    );
  }
}