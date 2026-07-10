import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../cubits/activities/tower_builder/tower_builder_state.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'tower_builder_pin_screen.dart';
import 'widgets/target_image_widget.dart';

class TowerBuilderBuildScreen extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const TowerBuilderBuildScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });

  @override
  State<TowerBuilderBuildScreen> createState() =>
      _TowerBuilderBuildScreenState();
}

class _TowerBuilderBuildScreenState extends State<TowerBuilderBuildScreen> {
  @override
  void initState() {
    super.initState();

    context.read<TowerBuilderCubit>().loadGame(
      activityId: widget.activityId,
      activitySessionId: widget.activitySessionId,
      childId: widget.childId,
      sessionId: widget.sessionId,
      startLevelId: widget.startLevelId,
    );
  }

  void _showHintComingSoon() {
    context.read<TowerBuilderCubit>().onHintPressed();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('التلميحات قادمة قريباً'),
      ),
    );
  }

  void _goToPinScreen(TowerBuilderLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<TowerBuilderCubit>(),
          child: TowerBuilderPinScreen(
            checklist: state.level.checklist,
            currentAttemptId: state.currentAttemptId,
            targetImageUrl: state.level.imageUrl,
          ),
        ),
      ),
    );
  }

  void _finishActivity() {
    Navigator.of(context).pop();
  }

  Widget _buildLevelTitle(TowerBuilderLoaded state) {
    return Column(
      children: [
        Text(
          'المستوى ${state.level.levelNumber}',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'التحدي',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPromptCard(String prompt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        prompt.isNotEmpty ? prompt : 'صورة البناء',
        textAlign: TextAlign.center,
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildAttemptPill(int attemptNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'المحاولة $attemptNumber',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildActionButtons(TowerBuilderLoaded state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _showHintComingSoon,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              side: const BorderSide(
                color: AppColors.secondary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.button.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text('أعطني تلميحاً'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _goToPinScreen(state),
            child: const Text('تم البناء'),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedContent(TowerBuilderLoaded state) {
    final level = state.level;

    return AppBackground(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopBar(
              leadingIcon: Icons.arrow_back_ios_new_rounded,
              onLeadingPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLevelTitle(state),
                      const SizedBox(height: 18),
                      _buildPromptCard(level.prompt),
                      const SizedBox(height: 18),
                      Expanded(
                        child: Center(
                          child: TargetImageWidget(
                            imageUrl: level.imageUrl,
                            prompt: level.prompt,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: _buildAttemptPill(state.attemptNumber),
                      ),
                      const SizedBox(height: 20),
                      _buildActionButtons(state),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return AppBackground(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TowerBuilderCubit, TowerBuilderState>(
        builder: (context, state) {
          if (state is TowerBuilderLoading) {
            return const AppBackground(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is TowerBuilderError) {
            return _buildError(state.message);
          }

          if (state is TowerBuilderLevelComplete) {
            return ActivityFeedbackView(
              type: ActivityFeedbackType.correct,
              onPrimaryPressed: _finishActivity,
            );
          }

          if (state is TowerBuilderLoaded) {
            return _buildLoadedContent(state);
          }

          return const AppBackground(
            child: SizedBox.expand(),
          );
        },
      ),
    );
  }
}
