import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/profile/profile_cubit.dart';
import '../../../models/childmode/child_model.dart';

class ChildrenSection extends StatefulWidget {
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final Function(ChildModel)? onChildSelected;
  final bool openAddChildDialog;

  const ChildrenSection({
    super.key,
    required this.children,
    this.selectedChild,
    this.onChildSelected,
    this.openAddChildDialog = false,
  });

  @override
  State<ChildrenSection> createState() => _ChildrenSectionState();
}

class _ChildrenSectionState extends State<ChildrenSection> {
  bool _hasOpenedDialog = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.openAddChildDialog && !_hasOpenedDialog) {
      _hasOpenedDialog = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showAddChildDialog(context);
      });
    }
  }

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
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: widget.children.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              if (i == widget.children.length) {
                return _buildAddButton(context);
              }

              return _buildChildItem(context, widget.children[i]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildItem(BuildContext context, ChildModel child) {
    final isSelected = widget.selectedChild?.id == child.id;

    return SizedBox(
      width: 68,
      child: GestureDetector(
        onTap: () {
          if (widget.onChildSelected != null) {
            widget.onChildSelected!(child);
          } else {
            context.read<ProfileCubit>().selectChild(child);
          }
        },
        onLongPress: () => _showChildInfoDialog(context, child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.white.withOpacity(0.75),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.border.withOpacity(0.65),
                  width: isSelected ? 2.4 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.22)
                        : AppColors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: ClipOval(
                  child: _ChildAvatarImage(child: child),
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              child.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11.5,
                height: 1,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: 68,
      child: GestureDetector(
        onTap: () => _showAddChildDialog(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white.withOpacity(0.75),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.7),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'إضافة',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 11.5,
                height: 1,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          title: const Text(
            'إضافة طفل',
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  hintText: 'الاسم',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                hint: const Text('الجنس'),
                value: selectedGender,
                items: const [
                  DropdownMenuItem(
                    value: 'MALE',
                    child: Text('ذكر'),
                  ),
                  DropdownMenuItem(
                    value: 'FEMALE',
                    child: Text('أنثى'),
                  ),
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

                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
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
                    selectedDate == null) {
                  return;
                }

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
    ).whenComplete(() {
      nameController.dispose();
    });
  }

  void _showChildInfoDialog(BuildContext context, ChildModel child) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          child.name,
          textAlign: TextAlign.right,
        ),
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


class _ChildAvatarImage extends StatelessWidget {
  final ChildModel child;

  const _ChildAvatarImage({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = child.avatarUrl?.trim();

    final imageUrl = avatarUrl != null && avatarUrl.isNotEmpty
        ? avatarUrl
        : 'https://api.dicebear.com/10.x/avataaars/png?seed=${Uri.encodeComponent(child.name)}&size=128';

    return Image.network(
      imageUrl,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.inputFill,
        child: const Icon(
          Icons.child_care_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      ),
    );
  }
}