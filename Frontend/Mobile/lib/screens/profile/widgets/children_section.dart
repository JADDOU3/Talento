import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/child_model.dart';
import '../../../cubits/profile/profile_cubit.dart';

class ChildrenSection extends StatelessWidget {
  final List<ChildModel> children;
  final ChildModel? selectedChild;

  const ChildrenSection({
    super.key,
    required this.children,
    this.selectedChild,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مستكشفيني',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == children.length) return _buildAddButton(context);
              return _buildChildItem(context, children[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildItem(BuildContext context, ChildModel child) {
    final isSelected = selectedChild?.id == child.id;
    return GestureDetector(
      onTap: () => context.read<ProfileCubit>().selectChild(child),
      onLongPress: () => _showChildInfoDialog(context, child),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
                  : [],
            ),
            child: ClipOval(
              child: Image.network(
                child.avatarUrl ??
                    'https://api.dicebear.com/7.x/adventurer/png?seed=${child.name}',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.inputFill,
                  child: const Icon(Icons.person_rounded, color: AppColors.hint),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            child.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddChildDialog(context),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputFill,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'إضافة',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddChildDialog(BuildContext context) {
    final nameController = TextEditingController();
    String? selectedGender;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('إضافة طفل', textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(hintText: 'الاسم'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text('الجنس'),
                value: selectedGender,
                items: const [
                  DropdownMenuItem(value: 'MALE', child: Text('ذكر')),
                  DropdownMenuItem(value: 'FEMALE', child: Text('أنثى')),
                ],
                onChanged: (v) => setState(() => selectedGender = v),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime(2018),
                    firstDate: DateTime(2010),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                child: Text(
                  selectedDate == null
                      ? 'اختر تاريخ الميلاد'
                      : '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    selectedGender == null ||
                    selectedDate == null) return;
                context.read<ProfileCubit>().addChild(
                  name: nameController.text,
                  dateOfBirth:
                  '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                  gender: selectedGender!,
                );
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChildInfoDialog(BuildContext context, ChildModel child) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(child.name, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('الجنس: ${child.gender == 'MALE' ? 'ذكر' : 'أنثى'}'),
            const SizedBox(height: 8),
            Text('تاريخ الميلاد: ${child.dateOfBirth ?? 'غير محدد'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}