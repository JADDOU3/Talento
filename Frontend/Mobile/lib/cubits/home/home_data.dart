import '../../models/childmode/child_model.dart';
import '../../models/kit/kit_model.dart';

class HomeData {
  final ChildModel? selectedChild;
  final KitModel? lastUsedKit;
  final int activitiesDoneCount;
  final int totalActivitiesCount;
  final int currentLevel;
  final int? latestActivitySessionId;

  const HomeData({
    this.selectedChild,
    this.lastUsedKit,
    this.activitiesDoneCount = 0,
    this.totalActivitiesCount = 0,
    this.currentLevel = 1,
    this.latestActivitySessionId,
  });

  double get progress {
    if (totalActivitiesCount == 0) return 0;
    return activitiesDoneCount / totalActivitiesCount;
  }

  bool get hasSelectedChild => selectedChild != null;

  bool get hasLastUsedKit => lastUsedKit != null;
}