import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../cubits/activities/tower_builder/tower_builder_state.dart';
import '../../models/activities/tower_builder/tower_builder_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/widgets/activity_feedback/activity_feedback_view.dart';
import 'widgets/checklist_item_widget.dart';

class TowerBuilderChecklistScreen extends StatefulWidget {
  final List<TowerBuilderChecklistItemModel> checklist;
  final int currentAttemptId;
  final String? targetImageUrl;

  const TowerBuilderChecklistScreen({
    super.key,
    required this.checklist,
    required this.currentAttemptId,
    required this.targetImageUrl,
  });

  @override
  State<TowerBuilderChecklistScreen> createState() =>
      _TowerBuilderChecklistScreenState();
}

class _TowerBuilderChecklistScreenState
    extends State<TowerBuilderChecklistScreen> {
  final Set<String> _checkedItemIds = {};

  bool _hasSubmitted = false;
  bool _isLeavingScreen = false;
  bool _isContinuingResult = false;

  void _toggleItem(String itemId) {
    if (_hasSubmitted) return;

    setState(() {
      if (_checkedItemIds.contains(itemId)) {
        _checkedItemIds.remove(itemId);
      } else {
        _checkedItemIds.add(itemId);
      }
    });
  }

  void _submitChecklist() {
    if (_hasSubmitted) return;

    final requiredItems = widget.checklist.where(
          (item) => item.requiredForCompletion,
    );

    final allRequiredChecked = requiredItems.every(
          (item) => _checkedItemIds.contains(item.id),
    );

    setState(() {
      _hasSubmitted = true;
    });

    context.read<TowerBuilderCubit>().onChecklistSubmitted(
      allChecked: allRequiredChecked,
    );
  }

  Future<void> _continueFromResult() async {
    if (_isContinuingResult) return;

    setState(() {
      _isContinuingResult = true;
    });

    await context.read<TowerBuilderCubit>().continueAfterChecklistResult();

    if (!mounted) return;

    if (context.read<TowerBuilderCubit>().state
    is TowerBuilderChecklistResult) {
      setState(() {
        _isContinuingResult = false;
      });
    }
  }

  void _closeChecklist() {
    if (_isLeavingScreen || !mounted) return;

    _isLeavingScreen = true;
    Navigator.of(context).pop();
  }

  Widget _buildTargetImage() {
    final imageUrl = widget.targetImageUrl;

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            'صورة البناء',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              'صورة البناء',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChecklistContent() {
    return AppBackground(
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تحقق من البناء',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTargetImage(),
                    const SizedBox(height: 20),
                    Text(
                      'ضع علامة على كل ما يطابق البناء',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: widget.checklist.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = widget.checklist[index];

                          return ChecklistItemWidget(
                            text: item.text,
                            isChecked: _checkedItemIds.contains(item.id),
                            onToggle: () => _toggleItem(item.id),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _hasSubmitted ? null : _submitChecklist,
                      child: const Text('إرسال'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocConsumer<TowerBuilderCubit, TowerBuilderState>(
          listener: (context, state) {
            if (_isLeavingScreen) return;

            // Emitted only after pressing the result button.
            if (_hasSubmitted && state is TowerBuilderLoaded) {
              _closeChecklist();
              return;
            }

            // The final activity result is displayed by the build screen.
            if (_hasSubmitted && state is TowerBuilderLevelComplete) {
              _closeChecklist();
              return;
            }

            if (state is TowerBuilderError && mounted) {
              setState(() {
                _hasSubmitted = false;
                _isContinuingResult = false;
              });
            }
          },
          builder: (context, state) {
            if (state is TowerBuilderChecklistResult) {
              return ActivityFeedbackView(
                type: state.allChecked
                    ? ActivityFeedbackType.correct
                    : ActivityFeedbackType.wrong,
                onPrimaryPressed: _isContinuingResult
                    ? null
                    : _continueFromResult,
              );
            }

            return _buildChecklistContent();
          },
        ),
      ),
    );
  }
}
