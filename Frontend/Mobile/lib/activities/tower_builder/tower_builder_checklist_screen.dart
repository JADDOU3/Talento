import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../cubits/activities/tower_builder/tower_builder_state.dart';
import '../../models/activities/tower_builder/tower_builder_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
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

  void _toggleItem(String itemId) {
    setState(() {
      if (_checkedItemIds.contains(itemId)) {
        _checkedItemIds.remove(itemId);
      } else {
        _checkedItemIds.add(itemId);
      }
    });
  }

  void _submitChecklist() {
    final requiredItems = widget.checklist.where(
          (item) => item.requiredForCompletion,
    );

    final allRequiredChecked = requiredItems.every(
          (item) => _checkedItemIds.contains(item.id),
    );

    _hasSubmitted = true;

    context.read<TowerBuilderCubit>().onChecklistSubmitted(
      allChecked: allRequiredChecked,
    );
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

  Widget _buildTitle() {
    return Text(
      'تحقق من البناء',
      textAlign: TextAlign.center,
      style: AppTextStyles.headlineMedium.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildInstruction() {
    return Text(
      'ضع علامة على كل ما يطابق البناء',
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: BlocListener<TowerBuilderCubit, TowerBuilderState>(
            listener: (context, state) {
              if (state is TowerBuilderLevelComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('أحسنت! اكتمل المستوى'),
                  ),
                );

                Navigator.of(context).pop();
                return;
              }

              if (state is TowerBuilderChecklistResult && !state.allChecked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لم يكتمل البناء، حاول مجدداً'),
                  ),
                );

                Navigator.of(context).pop();
                return;
              }

              if (_hasSubmitted && state is TowerBuilderLoaded) {
                Navigator.of(context).pop();
                return;
              }
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTitle(),

                    const SizedBox(height: 20),

                    _buildTargetImage(),

                    const SizedBox(height: 20),

                    _buildInstruction(),

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
                      onPressed: _submitChecklist,
                      child: const Text('إرسال'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}