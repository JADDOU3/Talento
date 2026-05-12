import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';





class ChildrenSection extends StatefulWidget {
  const ChildrenSection({super.key});

  @override
  State<ChildrenSection> createState() => _ChildrenSectionState();
}

class _ChildrenSectionState extends State<ChildrenSection> {
  int _selectedIndex = 0;

  final List<Map<String, String>> children = [
    {'name': 'مايا', 'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Maya'},
    {'name': 'أيو', 'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Ayo'},
    {'name': 'سارة', 'avatar': 'https://api.dicebear.com/7.x/adventurer/png?seed=Sara'},
  ];

  void _showAvatarDialog(String avatarUrl, String name) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.network(
                avatarUrl,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
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
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              if (i == children.length) return _buildAddButton();
              return _buildChildItem(i);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChildItem(int index) {
    final isSelected = index == _selectedIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      onLongPress: () => _showAvatarDialog(
        children[index]['avatar']!,
        children[index]['name']!,
      ),
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
                children[index]['avatar']!,
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
            children[index]['name']!,
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

  Widget _buildAddButton() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.inputFill,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.primary,
            size: 26,
          ),
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
    );
  }
}