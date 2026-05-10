import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/community/media_cubit.dart';
import '../../cubits/community/media_state.dart';
import '../../cubits/community/post_cubit.dart';
import '../../models/community/create_post.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();

  int? selectedKitId;
  File? selectedFile;
  String? uploadedS3Key;
  bool isUploading = false;

  final List<Map<String, dynamic>> kits = const [
    {'id': 1, 'name': 'حقيبة مستكشف الفضاء'},
    {'id': 2, 'name': 'حقيبة الروبوتات'},
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
    );

    if (result == null || result.files.single.path == null) {
      return;
    }

    final file = File(result.files.single.path!);

    setState(() {
      selectedFile = file;
      uploadedS3Key = null;
      isUploading = true;
    });

    context.read<MediaCubit>().uploadMedia(file);
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    if (content.isEmpty || isUploading) return;

    final success = await context.read<PostCubit>().createPost(
      CreatePost(
        content: content,
        kitId: selectedKitId,
        media: uploadedS3Key == null
            ? null
            : [
          MediaDto(
            type: 'IMAGE',
            s3Key: uploadedS3Key!,
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MediaCubit, MediaState>(
      listener: (context, state) {
        if (state is MediaUploading) {
          setState(() => isUploading = true);
        }

        if (state is MediaUploaded) {
          setState(() {
            uploadedS3Key = state.s3Key;
            isUploading = false;
          });
        }

        if (state is MediaError) {
          setState(() => isUploading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Directionality(
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
                    OutlinedButton.icon(
                      onPressed: isUploading ? null : _pickMedia,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        selectedFile == null
                            ? 'اختيار صورة أو فيديو'
                            : uploadedS3Key != null
                            ? 'تم رفع الملف'
                            : 'تم اختيار ملف',
                      ),
                    ),
                    if (isUploading) ...[
                      const SizedBox(height: 10),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isUploading ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        isUploading ? 'جاري رفع الملف...' : 'نشر',
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