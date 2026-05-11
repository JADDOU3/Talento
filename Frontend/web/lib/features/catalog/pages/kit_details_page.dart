// lib/features/catalog/pages/kit_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/kit/kit_cubit.dart';
import '../cubits/kit/kit_state.dart';
import '../../../shared/models/kit_model.dart';
import '../../../util/theme/app_colors.dart';

class KitDetailsPage extends StatefulWidget {
  const KitDetailsPage({super.key});

  @override
  State<KitDetailsPage> createState() => _KitDetailsPageState();
}

class _KitDetailsPageState extends State<KitDetailsPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final kitId = ModalRoute.of(context)?.settings.arguments as int?;
      if (kitId != null) {
        context.read<KitCubit>().getKitById(kitId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kit Details',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<KitCubit, KitState>(
        builder: (context, state) {
          if (state is KitLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          if (state is KitError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                final kitId =
                    ModalRoute.of(context)?.settings.arguments as int?;
                if (kitId != null) {
                  context.read<KitCubit>().getKitById(kitId);
                }
              },
            );
          }

          if (state is KitDetailsLoaded) {
            return _DetailsBody(kit: state.kit);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Details Body ──────────────────────────────────────────────────────────────
class _DetailsBody extends StatelessWidget {
  final KitModel kit;
  const _DetailsBody({required this.kit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image ──────────────────────────────────────────────────
          _KitImage(imageURL: kit.imageURL),

          // ── Content ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Labels row
                Row(
                  children: [
                    if (kit.type.isNotEmpty)
                      _Label(label: kit.type, color: AppColors.teal),
                    if (kit.mindsetName != null &&
                        kit.mindsetName!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _Label(
                          label: kit.mindsetName!,
                          color: const Color(0xFFFF6B6B)),
                    ],
                    if (kit.isNew) ...[
                      const SizedBox(width: 8),
                      _Label(
                          label: 'NEW',
                          color: const Color(0xFFFF4D6D),
                          filled: true),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  kit.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                Text(
                  '\$${kit.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  kit.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.65,
                  ),
                ),

                // Kit Items
                if (kit.kitItems.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text(
                    "What's Inside",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...kit.kitItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Add to Cart
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${kit.name} added to cart'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.teal,
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ───────────────────────────────────────────────────────────────
class _KitImage extends StatelessWidget {
  final String imageURL;
  const _KitImage({required this.imageURL});

  @override
  Widget build(BuildContext context) {
    if (imageURL.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
            child: Icon(Icons.image_not_supported,
                size: 60, color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Image.network(
        imageURL,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 320,
          color: Colors.grey[200],
          child: const Center(
              child:
                  Icon(Icons.broken_image, size: 60, color: Colors.grey)),
        ),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 320,
            color: Colors.grey[100],
            child: const Center(
                child:
                    CircularProgressIndicator(color: AppColors.teal)),
          );
        },
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _Label({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: filled ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              message == 'Unauthorized'
                  ? Icons.lock_outline
                  : Icons.error_outline,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: onRetry,
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}