import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/activities/tower_builder/tower_builder_cubit.dart';
import '../../cubits/activities/tower_builder/tower_builder_state.dart';
import '../../models/activities/tower_builder/tower_builder_checklist_item_model.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/checklist_item_widget.dart';

class TowerBuilderChecklistScreen extends StatefulWidget {
  final List<TowerBuilderChecklistItemModel> checklist;
  final int currentAttemptId;

  const TowerBuilderChecklistScreen({
    super.key,
    required this.checklist,
    required this.currentAttemptId,
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
    final allChecked = _checkedItemIds.length == widget.checklist.length;

    _hasSubmitted = true;

    context.read<TowerBuilderCubit>().onChecklistSubmitted(
      allChecked: allChecked,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: BlocListener<TowerBuilderCubit, TowerBuilderState>(
          listener: (context, state) {
            if (state is TowerBuilderLevelComplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Level complete!'),
                ),
              );

              Navigator.of(context).pop();
              return;
            }

            if (state is TowerBuilderChecklistResult && !state.allChecked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Some items were not checked. Try again!'),
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
                  const Text(
                    'Check everything that matches the build:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
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
                    child: const Text('Submit'),
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