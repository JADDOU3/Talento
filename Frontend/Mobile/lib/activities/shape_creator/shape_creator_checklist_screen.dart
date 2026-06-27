import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/shape_creator/shape_creator_cubit.dart';
import '../../cubits/activities/shape_creator/shape_creator_state.dart';
import '../../models/activities/shape_creator/shape_creator_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/checklist_item_widget.dart';

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
  _hasSubmitted = true;

  final requiredItems = widget.checklist
      .where((item) => item.text != 'هل تمت مساعدته')
      .toList();

  final checkedRequiredItems = requiredItems
      .where((item) => _checkedItemIds.contains(item.id))
      .toList();

  final allChecked =
      checkedRequiredItems.length == requiredItems.length;

  context.read<ShapeCreatorCubit>().onChecklistSubmitted(
    allChecked: allChecked,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: BlocListener<ShapeCreatorCubit, ShapeCreatorState>(
          listener: (context, state) {
            if (state is ShapeCreatorLevelComplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('أحسنت! اكتمل المستوى'),
                ),
              );

              Navigator.of(context).pop();
              return;
            }

            if (state is ShapeCreatorChecklistResult && !state.allChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('لم يكتمل البناء، حاول مجدداً'),
                ),
              );

             // Navigator.of(context).pop();
              return;
            }

            if (_hasSubmitted && state is ShapeCreatorLoaded) {
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
                  const Text(
                    'تحقق من البناء:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (widget.targetImageUrl != null &&
                     widget.targetImageUrl!.isNotEmpty) ...[
                   ClipRRect(
                     borderRadius: BorderRadius.circular(16),
                     child: Image.network(
                       widget.targetImageUrl!,
                       height: 220,
                       fit: BoxFit.contain,
                    ),
                   ),
                   const SizedBox(height: 20),
                 ],

                  const Text(
                    'ضع علامة على كل ما يطابق البناء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                 const SizedBox(height: 24),

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
    );
  }
}