import 'package:flutter/material.dart';

class TargetImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String prompt;

  const TargetImageWidget({
    super.key,
    required this.imageUrl,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
        imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _Placeholder(prompt: prompt);
        },
      )
          : _Placeholder(prompt: prompt),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String prompt;

  const _Placeholder({
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    final placeholderText = prompt.trim().isNotEmpty ? prompt : 'صورة البناء';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          placeholderText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}