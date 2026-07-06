import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../models/activities/shape_creator/shape_creator_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
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
  bool _shouldCloseOnNextLoaded = false;
  bool _isClosing = false;
  bool _didShowSuccessMessage = false;
  List<String> _missingRequiredTexts = [];

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

    final missingRequiredItems = _requiredItems.where(
          (item) => !_checkedItemIds.contains(item.id),
    );

    final missingTexts = missingRequiredItems
        .map((item) => item.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    final allRequiredChecked = missingTexts.isEmpty;

    setState(() {
      _hasSubmitted = true;
      _shouldCloseOnNextLoaded = allRequiredChecked;
      _missingRequiredTexts = missingTexts;
    });

    context.read<ShapeCreatorCubit>().onChecklistSubmitted(
      allChecked: allRequiredChecked,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  void _showSuccessMessage() {
    if (_didShowSuccessMessage) return;

    _didShowSuccessMessage = true;
    _showSnackBar('أحسنت! تم البناء بنجاح 🎉');
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
          child: BlocListener<ShapeCreatorCubit, ShapeCreatorState>(
            listener: (context, state) {
              if (_isClosing) return;

              if (state is ShapeCreatorLevelComplete) {
                _isClosing = true;
                _showSuccessMessage();
                Navigator.of(context).pop();
                return;
              }

              if (state is ShapeCreatorChecklistResult && !state.allChecked) {
                _isClosing = true;

                final missingText = _missingRequiredTexts.isEmpty
                    ? 'أحد الشروط الأساسية غير مكتمل.'
                    : 'الشروط الناقصة: ${_missingRequiredTexts.join('، ')}';

                _showSnackBar('$missingText\nحاول مرة أخرى.');
                Navigator.of(context).pop();
                return;
              }

              if (_hasSubmitted &&
                  _shouldCloseOnNextLoaded &&
                  state is ShapeCreatorLevelFinished) {
                _showSuccessMessage();
                return;
              }

              if (_hasSubmitted &&
                  _shouldCloseOnNextLoaded &&
                  state is ShapeCreatorLoaded) {
                _isClosing = true;
                _showSuccessMessage();
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
                      onPressed: _hasSubmitted ? null : _submitChecklist,
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
