import 'package:flutter/material.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/roadmap/roadmap_activity_model.dart';
import '../../models/roadmap/roadmap_model.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../roadmap/roadmap_screen.dart';
import 'widgets/active_journey_map_section.dart';
import 'widgets/curriculum_path_section.dart';
import 'widgets/owned_kit_header.dart';
import 'widgets/primary_button.dart';
import '../../shared/layout/top_bar.dart';

class OwnedKitScreen extends StatefulWidget {
  final dynamic kit;
  final int? childId;

  const OwnedKitScreen({
    super.key,
    required this.kit,
    this.childId,
  });

  @override
  State<OwnedKitScreen> createState() => _OwnedKitScreenState();
}

class _OwnedKitScreenState extends State<OwnedKitScreen> {
  final RoadmapService _roadmapService = RoadmapService();

  Future<RoadmapModel>? _roadmapFuture;

  int? get _kitId {
    final id = _readKitValue('id');

    if (id is int) return id;
    return int.tryParse(id?.toString() ?? '');
  }

  String get _kitName => _readKitText('name');

  String get _kitDescription => _readKitText('description');

  String get _kitImageUrl => _normalizeImageUrl(
    _readKitText('imageUrl').isNotEmpty
        ? _readKitText('imageUrl')
        : _readKitText('imageURL'),
  );

  @override
  void initState() {
    super.initState();
    _loadRoadmapSections();
  }

  @override
  void didUpdateWidget(covariant OwnedKitScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.kit != widget.kit || oldWidget.childId != widget.childId) {
      _loadRoadmapSections();
    }
  }

  void _loadRoadmapSections() {
    final kitId = _kitId;
    final childId = widget.childId;

    if (kitId == null || childId == null) {
      _roadmapFuture = null;
      return;
    }

    _roadmapFuture = _roadmapService.getRoadmap(
      kitId: kitId,
      childId: childId,
    );
  }

  void _retryRoadmapSections() {
    setState(_loadRoadmapSections);
  }

  Future<void> _openRoadmapAtCurrentActivity(BuildContext context) async {
    final kitId = _kitId;
    final childId = widget.childId;

    if (kitId == null) {
      _showSnackBar(
        context,
        'لا يمكن فتح خارطة الرحلة لأن رقم الصندوق غير متوفر',
      );
      return;
    }

    if (childId == null) {
      _showSnackBar(
        context,
        'اختاري طفلًا أولًا حتى تظهر رحلة التعلّم',
      );
      return;
    }

    try {
      _roadmapFuture ??= _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      final roadmap = await _roadmapFuture;
      final activities = roadmap?.activities ?? <RoadmapActivityModel>[];

      final currentIndex = activities.indexWhere(
            (activity) => activity.isCurrent,
      );

      if (!mounted) return;

      if (currentIndex == -1) {
        _openRoadmap(context);
        return;
      }

      final currentActivity = activities[currentIndex];

      _openRoadmap(
        context,
        initialActivityId: currentActivity.activityId,
        initialActivityIndex: currentIndex,
      );
    } catch (_) {
      if (!mounted) return;

      _showSnackBar(
        context,
        'تعذر فتح النشاط الحالي، جرّبي مرة ثانية',
      );
    }
  }

  void _openRoadmap(
      BuildContext context, {
        int? initialActivityId,
        int? initialActivityIndex,
      }) {
    final kitId = _kitId;
    final childId = widget.childId;

    if (kitId == null) {
      _showSnackBar(
        context,
        'لا يمكن فتح خارطة الرحلة لأن رقم الصندوق غير متوفر',
      );
      return;
    }

    if (childId == null) {
      _showSnackBar(
        context,
        'اختاري طفلًا أولًا حتى تظهر رحلة التعلّم',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: RoadmapScreen.routeName),
        builder: (_) => RoadmapScreen(
          kitId: kitId,
          childId: childId,
          initialActivityId: initialActivityId,
          initialActivityIndex: initialActivityIndex,
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  dynamic _readKitValue(String field) {
    final kit = widget.kit;

    if (kit is Map) {
      return kit[field];
    }

    try {
      switch (field) {
        case 'id':
          return kit.id;
        case 'name':
          return kit.name;
        case 'description':
          return kit.description;
        case 'imageUrl':
          return kit.imageUrl;
        case 'imageURL':
          return kit.imageURL;
      }
    } catch (_) {}

    return null;
  }

  String _readKitText(String field) {
    final value = _readKitValue(field);
    final text = value?.toString().trim() ?? '';
    return text == 'null' ? '' : text;
  }

  String _normalizeImageUrl(String value) {
    final image = value.trim();

    if (image.isEmpty) return '';

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    final cleanBaseUrl = ApiConstants.baseUrl
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/$'), '');

    final cleanImagePath = image.startsWith('/') ? image.substring(1) : image;

    return '$cleanBaseUrl/$cleanImagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: SafeArea(
            child: Column(
              children: [
                TopBar(
                  leadingIcon: Icons.arrow_back_ios_rounded,
                  onLeadingPressed: () => Navigator.pop(context),
                ),
                _buildScreenTitle(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 8, 18, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OwnedKitHeader(
                          name: _kitName,
                          description: _kitDescription,
                          imageUrl: _kitImageUrl,
                          onResume: () => _openRoadmapAtCurrentActivity(context),
                        ),
                        const SizedBox(height: 22),
                        _buildRoadmapContent(context),
                        const SizedBox(height: 22),
                      ],
                    ),
                  ),
                ),
                const BottomNavBar(selectedIndex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoadmapContent(BuildContext context) {
    if (widget.childId == null || _roadmapFuture == null) {
      return _buildRoadmapMessage(
        icon: Icons.child_care_rounded,
        message: 'اختاري طفلًا أولًا حتى تظهر رحلة التعلّم',
      );
    }

    return FutureBuilder<RoadmapModel>(
      future: _roadmapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildRoadmapLoading();
        }

        if (snapshot.hasError) {
          return _buildRoadmapError(
            snapshot.error.toString().replaceFirst('Exception: ', ''),
          );
        }

        final roadmap = snapshot.data;
        final activities = roadmap?.activities ?? <RoadmapActivityModel>[];

        if (activities.isEmpty) {
          return _buildRoadmapMessage(
            icon: Icons.route_outlined,
            message: 'لم تبدأ أي نشاط بعد',
          );
        }

        final currentActivity = _findCurrentActivity(activities);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ActiveJourneyMapSection(
              activities: activities,
              onCurrentActivityTap: (activity, activityIndex) {
                _openRoadmap(
                  context,
                  initialActivityId: activity.activityId,
                  initialActivityIndex: activityIndex,
                );
              },
            ),
            if (currentActivity != null) ...[
              const SizedBox(height: 20),
              CurriculumPathSection(
                activity: currentActivity,
                onOpenRoadmap: () {
                  final currentIndex = activities.indexWhere(
                        (activity) => identical(activity, currentActivity),
                  );

                  _openRoadmap(
                    context,
                    initialActivityId: currentActivity.activityId,
                    initialActivityIndex:
                    currentIndex == -1 ? null : currentIndex,
                  );
                },
              ),
            ],
          ],
        );
      },
    );
  }

  RoadmapActivityModel? _findCurrentActivity(
      List<RoadmapActivityModel> activities,
      ) {
    for (final activity in activities) {
      if (activity.isCurrent) return activity;
    }

    return null;
  }

  Widget _buildRoadmapLoading() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSkeletonLine(width: 170),
          const SizedBox(height: 18),
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.inputFill,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSkeletonLine(width: 34),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLine({required double width}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: width,
        height: 12,
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildRoadmapError(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.error.withOpacity(0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            'صار خطأ أثناء تحميل رحلة الصندوق',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (message.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Retry',
            height: 44,
            onPressed: _retryRoadmapSections,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapMessage({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.96),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.78),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.white.withOpacity(0.92),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 13,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _topCircleButton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.arrow_back_ios_rounded,
            ),
            const Spacer(),
            Image.asset(
              'assets/icons/logo1.png',
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Text(
                  'Talento',
                  style: TextStyle(
                    fontFamily: 'BerlinSans',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Center(
        child: Text(
          'تفاصيل الصندوق',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1,
          ),
        ),
      ),
    );
  }

  Widget _topCircleButton({
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Material(
      color: AppColors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
    );
  }
}