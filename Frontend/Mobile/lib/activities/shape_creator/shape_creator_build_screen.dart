import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/target_image_widget.dart';
import 'shape_creator_pin_screen.dart';

class ShapeCreatorBuildScreen extends StatefulWidget {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  const ShapeCreatorBuildScreen({
    super.key,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  });

  @override
  State<ShapeCreatorBuildScreen> createState() =>
      _ShapeCreatorBuildScreenState();
}

class _ShapeCreatorBuildScreenState extends State<ShapeCreatorBuildScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ShapeCreatorCubit>().loadGame(
      activityId: widget.activityId,
      activitySessionId: widget.activitySessionId,
      childId: widget.childId,
      sessionId: widget.sessionId,
    );
  }

  void _showHintComingSoon() {
    context.read<ShapeCreatorCubit>().onHintPressed();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('التلميحات قادمة قريباً'),
      ),
    );
  }

  void _goToPinScreen(ShapeCreatorLoaded state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ShapeCreatorCubit>(),
          child: ShapeCreatorPinScreen(
            checklist: state.level.checklist,
            currentAttemptId: state.currentAttemptId,
            targetImageUrl:
            state.level.challengeImages[state.currentChallengeIndex],
          ),
        ),
      ),
    );
  }

  void _finishActivity() {
    Navigator.of(context).pop();
  }

  Widget _buildTopBar(Duration elapsed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.inputFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timer_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDuration(elapsed),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            'Talento',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildActionButtons(ShapeCreatorLoaded state) {
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

  Widget _buildLoadedContent(ShapeCreatorLoaded state) {
    final level = state.level;
    final currentImage = level.challengeImages[state.currentChallengeIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(state.elapsed),
              const SizedBox(height: 18),
              _buildPromptCard(level.prompt),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: TargetImageWidget(
                    imageUrl: currentImage,
                    prompt: level.prompt,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(child: _buildAttemptPill(state.attemptNumber)),
              const SizedBox(height: 20),
              _buildActionButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelComplete(int levelNumber) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.check_circle,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'ممتاز! لقد أنهيت المستوى $levelNumber',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _finishActivity,
                child: const Text('إنهاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Directionality(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: BlocBuilder<ShapeCreatorCubit, ShapeCreatorState>(
          builder: (context, state) {
            if (state is ShapeCreatorLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ShapeCreatorError) {
              return _buildError(state.message);
            }

            if (state is ShapeCreatorLevelFinished) {
              return _buildLevelComplete(state.levelNumber);
            }

            if (state is ShapeCreatorLoaded) {
              return _buildLoadedContent(state);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes =
  duration.inMinutes.remainder(60).toString().padLeft(2, '0');

  final seconds =
  duration.inSeconds.remainder(60).toString().padLeft(2, '0');

  return '$minutes:$seconds';
}