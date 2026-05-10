import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/community/post_cubit.dart';
import '../../models/community/create_post.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  int? selectedKitId;

  final List<Map<String, dynamic>> kits = const [
    {'id': 1, 'name': 'حقيبة مستكشف الفضاء'},
    {'id': 2, 'name': 'حقيبة الروبوتات'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _createPost() {
    final content = _contentController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (content.isEmpty) return;

    context.read<PostCubit>().createPost(
      CreatePost(
        content: content,
        kitId: selectedKitId,
        media: imageUrl.isEmpty
            ? null
            : [
          MediaDto(
            type: 'IMAGE',
            url: imageUrl,
          ),
        ],
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'شارك قصتك',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _contentController,
                    maxLines: 4,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    decoration: _inputDecoration('اكتب محتوى المنشور...'),
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<int?>(
                    value: selectedKitId,
                    decoration: _inputDecoration('اختر الحقيبة (اختياري)'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('بدون حقيبة'),
                      ),
                      ...kits.map(
                            (kit) => DropdownMenuItem<int?>(
                          value: kit['id'],
                          child: Text(kit['name']),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedKitId = value);
                    },
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _imageUrlController,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration('رابط صورة اختياري'),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _createPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      'نشر',
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }
}