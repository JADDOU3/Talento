import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../models/activities/shape_creator/shape_creator_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../tower_builder/widgets/checklist_item_widget.dart';

class ShapeCreatorChecklistScreen extends StatefulWidget {
  final List<ShapeCreatorChecklistItemModel> checklist;
  final int currentAttemptId;
  final String? targetImageUrl;

  const ShapeCreatorChecklistScreen({
    super.key,
    required this.checklist,
    required this.currentAttemptId,
    required this.targetImageUrl,
  });

  @override
  State<ShapeCreatorChecklistScreen> createState() =>
      _ShapeCreatorChecklistScreenState();
}

class _ShapeCreatorChecklistScreenState
    extends State<ShapeCreatorChecklistScreen> {
  final Set<String> _checkedItemIds = {};

  bool _hasSubmitted = false;
  bool _isLeavingScreen = false;

  List<ShapeCreatorChecklistItemModel> get _requiredItems {
    if (widget.checklist.length >= 2) {
      return widget.checklist.take(2).toList();
    }

    return widget.checklist
        .where((item) => item.text.trim() != 'هل تمت مساعدته')
        .toList();
  }

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

    final allRequiredChecked = _requiredItems.every(
          (item) => _checkedItemIds.contains(item.id),
    );

    setState(() {
      _hasSubmitted = true;
    });

    context.read<ShapeCreatorCubit>().onChecklistSubmitted(
      allChecked: allRequiredChecked,
    );
  }

  void _closeChecklist() {
    if (_isLeavingScreen || !mounted) return;

    _isLeavingScreen = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
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
        body: BlocConsumer<ShapeCreatorCubit, ShapeCreatorState>(
          listener: (context, state) {
            if (_isLeavingScreen) return;

            /*
             * The shared feedback is displayed by ShapeCreatorBuildScreen.
             * Close this checklist route as soon as any result is ready.
             */
            if (_hasSubmitted &&
                (state is ShapeCreatorChecklistResult ||
                    state is ShapeCreatorLevelComplete)) {
              _closeChecklist();
              return;
            }

            if (state is ShapeCreatorError && mounted) {
              setState(() {
                _hasSubmitted = false;
              });
            }
          },
          builder: (context, state) {
            if (_hasSubmitted) {
              return const AppBackground(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return _buildChecklistContent();
          },
        ),
      ),
    );
  }
}
