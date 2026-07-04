import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/config/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/community/media_cubit.dart';
import '../../cubits/community/media_state.dart';
import '../../cubits/community/post_cubit.dart';
import '../../cubits/community/post_state.dart';
import '../../models/community/create_post.dart';
import '../../models/kit/kit_model.dart';
import '../../services/auth/auth_api_client.dart';
import '../../services/kit/kit_service.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final TextEditingController _contentController = TextEditingController();
  final AuthApiClient _client = AuthApiClient();
  final KitService _kitService = KitService();

  static const String _headerAsset = 'assets/images/share_story_header.png';

  int? selectedKitId;
  File? selectedFile;
  String? uploadedS3Key;
  bool isUploading = false;
  bool isCheckingSelectedChild = false;
  bool isLoadingKits = true;
  String? kitsError;
  List<KitModel> kits = [];

  @override
  void initState() {
    super.initState();
    _loadKits();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadKits() async {
    setState(() {
      isLoadingKits = true;
      kitsError = null;
    });

    try {
      final loadedKits = await _kitService.getAllKits(size: 50);
      if (!mounted) return;

      setState(() {
        kits = loadedKits;
        isLoadingKits = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        kitsError = e.toString();
        selectedKitId = null;
        isLoadingKits = false;
      });
    }
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      selectedFile = file;
      uploadedS3Key = null;
      isUploading = true;
    });

    context.read<MediaCubit>().uploadMedia(file);
  }

  Future<bool> _hasSelectedChild() async {
    setState(() => isCheckingSelectedChild = true);

    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.selectedChild),
      );

      print('SELECTED CHILD STATUS: ${response.statusCode}');
      print('SELECTED CHILD BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return false;

        final body = jsonDecode(response.body);

        if (body == null) return false;

        if (body is Map<String, dynamic>) {
          final data = body['data'] ?? body['child'] ?? body['result'] ?? body;
          return data is Map<String, dynamic> && data['id'] != null;
        }

        return false;
      }

      return false;
    } catch (e) {
      print('SELECTED CHILD ERROR: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => isCheckingSelectedChild = false);
      }
    }
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    print('========== CREATE POST ==========');
    print('content: $content');
    print('kitId: $selectedKitId');
    print('s3Key: $uploadedS3Key');

    if (content.isEmpty || isUploading || isCheckingSelectedChild) {
      print('blocked: empty or uploading or checking selected child');
      return;
    }

    final hasChild = await _hasSelectedChild();

    if (!mounted) return;

    if (!hasChild) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد طفل محدد، اختاري طفل أولاً'),
        ),
      );
      return;
    }

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

    print('success: $success');

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      context.read<PostCubit>().getAllPosts();
    }
  }

  void _closeSheet() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  void _unfocusOnly() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return MultiBlocListener(
      listeners: [
        BlocListener<MediaCubit, MediaState>(
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
        ),
        BlocListener<PostCubit, PostState>(
          listener: (context, state) {
            if (state is PostError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeSheet,
          child: SafeArea(
            top: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: 14,
                right: 14,
                top: 22,
                bottom: bottomInset + 22,
              ),
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _unfocusOnly,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: screenHeight * 0.86,
                      maxWidth: 430,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFFEFC),
                              Color(0xFFFFFBF7),
                              Color(0xFFF7FFFD),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.16),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.border,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  14,
                                  14,
                                  14,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFDFB),                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: const Color(0xFFF2EAE2),                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.black
                                          .withValues(alpha: 0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    const _HeaderImage(
                                      assetPath: _headerAsset,
                                    ),
                                    const SizedBox(height: 14),
                                    _ContentInput(
                                      controller: _contentController,
                                    ),
                                    const SizedBox(height: 14),
                                    _KitSelector(
                                      selectedKitId: selectedKitId,
                                      kits: kits,
                                      isLoadingKits: isLoadingKits,
                                      kitsError: kitsError,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedKitId = value;
                                        });
                                      },
                                      onRetry: _loadKits,
                                    ),
                                    const SizedBox(height: 14),
                                    _MediaPickerCard(
                                      selectedFile: selectedFile,
                                      uploadedS3Key: uploadedS3Key,
                                      isUploading: isUploading,
                                      onTap:
                                      isUploading ? null : _pickMedia,
                                    ),
                                    if (isUploading) ...[
                                      const SizedBox(height: 10),
                                      ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(99),
                                        child: const SizedBox(
                                          height: 4,
                                          child: LinearProgressIndicator(
                                            color: AppColors.primary,
                                            backgroundColor:
                                            AppColors.inputFill,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    _PublishButton(
                                      isUploading: isUploading,
                                      isCheckingSelectedChild:
                                      isCheckingSelectedChild,
                                      onPressed: isUploading ||
                                          isCheckingSelectedChild
                                          ? null
                                          : _createPost,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final String assetPath;

  const _HeaderImage({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 2.2,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.pink.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'شارك قصتك',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'أخبر أصدقاء تالينتو عن إنجازك أو تجربتك الرائعة!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ContentInput extends StatelessWidget {
  final TextEditingController controller;

  const _ContentInput({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.78),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        minLines: 4,
        maxLength: 1000,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        cursorColor: AppColors.primary,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
          height: 1.5,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'اكتب محتوى المنشور...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          counterStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          filled: true,
          fillColor: AppColors.white.withValues(alpha: 0.96),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        ),
      ),
    );
  }
}

class _KitSelector extends StatelessWidget {
  final int? selectedKitId;
  final List<KitModel> kits;
  final bool isLoadingKits;
  final String? kitsError;
  final ValueChanged<int?> onChanged;
  final VoidCallback onRetry;

  const _KitSelector({
    required this.selectedKitId,
    required this.kits,
    required this.isLoadingKits,
    required this.kitsError,
    required this.onChanged,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 7),
            Text(
              'اختر الصندوق',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int?>(
          value: selectedKitId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white.withValues(alpha: 0.96),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.8),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('بدون صندوق'),
            ),
            ...kits.map(
                  (kit) => DropdownMenuItem<int?>(
                value: kit.id,
                child: Text(kit.name),
              ),
            ),
          ],
          onChanged: isLoadingKits || kitsError != null ? null : onChanged,
        ),
        if (isLoadingKits) ...[
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: const SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.inputFill,
              ),
            ),
          ),
        ],
        if (kitsError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'تعذر تحميل الصناديق',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MediaPickerCard extends StatelessWidget {
  final File? selectedFile;
  final String? uploadedS3Key;
  final bool isUploading;
  final VoidCallback? onTap;

  const _MediaPickerCard({
    required this.selectedFile,
    required this.uploadedS3Key,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = selectedFile == null
        ? 'اختيار صورة أو فيديو'
        : uploadedS3Key != null
        ? 'تم رفع الملف'
        : 'تم اختيار ملف';

    final icon = uploadedS3Key != null
        ? Icons.check_circle_rounded
        : Icons.add_photo_alternate_outlined;

    final color = uploadedS3Key != null ? AppColors.primary : AppColors.pink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 76,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.pink.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.pink.withValues(alpha: 0.82),
              width: 1.3,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                isUploading ? 'جاري رفع الملف...' : label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublishButton extends StatelessWidget {
  final bool isUploading;
  final bool isCheckingSelectedChild;
  final VoidCallback? onPressed;

  const _PublishButton({
    required this.isUploading,
    required this.isCheckingSelectedChild,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = isUploading
        ? 'جاري رفع الملف...'
        : isCheckingSelectedChild
        ? 'جاري التحقق من الطفل...'
        : 'نشر';

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
          foregroundColor: AppColors.white,
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}